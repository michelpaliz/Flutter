import 'dart:convert'; // ✅ NEW
import 'dart:developer' as devtools show log;
import 'dart:io'; // ✅ NEW

import 'package:calendar_app_frontend/b-backend/api/blobUploader/blob_uploader.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // ✅ NEW
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // ✅ NEW
import 'package:uuid/uuid.dart';

import '../../../../../../../a-models/group_model/calendar/calendar.dart';
import '../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../a-models/notification_model/userInvitation_status.dart';
import '../../../../../../../a-models/user_model/user.dart';
import '../../../../../../../b-backend/api/auth/auth_database/auth_provider.dart'; // ✅ NEW

import '../../../../../../../b-backend/api/config/api_constants.dart'; // ✅ NEW
import '../../../../../../../b-backend/api/user/user_services.dart';
import '../../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../../d-stateManagement/user/user_management.dart';

class GroupController extends ChangeNotifier {
  BuildContext? context;

  // Services
  final UserService _userService = UserService();
  late NotificationManagement notificationManagement;
  late UserManagement userManagement;
  late GroupManagement groupManagement;

  // UI Values
  String groupName = '';
  String groupDescription = '';
  XFile? selectedImage;

  User? currentUser;
  List<User> usersInGroup = []; // List of users in the group
  Map<String, String> userRoles = {}; // Mapping for user roles

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  GroupController() {
    usersInGroup = [];
  }

  void initialize({
    required User user,
    required UserManagement userManagement,
    required GroupManagement groupManagement,
    required NotificationManagement notificationManagement,
    required BuildContext context,
  }) {
    this.context = context;
    this.userManagement = userManagement;
    this.groupManagement = groupManagement;
    this.notificationManagement = notificationManagement;
    this.currentUser = user;

    usersInGroup = [user]; // Set the current user as the initial member
    userRoles = {user.userName: 'Administrator'};

    // Ensure GroupManagement has the current user
    groupManagement.setCurrentUser(user);
  }

  void addUser(User newUser) {
    if (!usersInGroup.any((u) => u.userName == newUser.userName)) {
      usersInGroup.add(newUser);
      userRoles[newUser.userName] = 'Member';
      notifyListeners();
    }
  }

  void onRolesUpdated(Map<String, String> updatedUserRoles) {
    userRoles = updatedUserRoles;
    notifyListeners();
  }

  void removeUser(String username) {
    if (username == currentUser?.userName) {
      _showSnackBar(AppLocalizations.of(context!)!.cannotRemoveYourself);
      return;
    }
    usersInGroup.removeWhere((u) => u.userName == username);
    userRoles.remove(username);
    notifyListeners();
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) selectedImage = image;
    notifyListeners();
  }

  void _showSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  bool hasAtLeastOneUser() => userRoles.isNotEmpty;

  // Public entry from UI
  Future<void> submitGroupFromUI() async {
    groupName = nameController.text.trim();
    groupDescription = descriptionController.text.trim();

    if (groupName.isEmpty || groupDescription.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context!)!.requiredTextFields);
      return;
    }

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final ok = await _createGroupAndMaybeUploadPhoto(); // ✅ UPDATED

    if (context!.mounted) {
      Navigator.of(context!).pop(); // close loading
      if (ok) {
        _showSnackBar(AppLocalizations.of(context!)!.groupCreated);
        Navigator.of(context!).pop(); // back
      } else {
        _showSnackBar(AppLocalizations.of(context!)!.failedToCreateGroup);
      }
    }
  }

  // ✅ UPDATED: create first, then upload image (if any), then PATCH group
  Future<bool> _createGroupAndMaybeUploadPhoto() async {
    try {
      // Prefer letting server assign IDs; keep local UUIDs if your API requires.
      final calendarId = const Uuid().v4().substring(0, 10);

      // Ensure we have the server-side user (you already do this)
      final serverUser =
          await _userService.getUserByUsername(currentUser!.userName);

      // Owner/admin role (align keying with your backend; using username here like before)
      final adminRoles = {currentUser!.userName: 'Administrator'};

      // Create group WITHOUT photo first
      final newGroup = Group(
        id: '', // let backend assign Mongo _id
        name: groupName,
        ownerId: currentUser!.id,
        userRoles: adminRoles,
        userIds: [currentUser!.id],
        createdTime: DateTime.now(),
        description: groupDescription,
        photoUrl: '', // no photo yet
        photoBlobName: null,
        calendar: Calendar(calendarId, groupName),
        invitedUsers:
            _buildInvites(), // from userRoles (excluding current user)
      );

      final createdOk =
          await groupManagement.createGroup(newGroup, userManagement);
      if (!createdOk) return false;

      // Get the created group (you can refine this lookup per your app logic)
      final created = groupManagement.groups.lastWhere(
        (g) => g.name == newGroup.name && g.ownerId == newGroup.ownerId,
        orElse: () => groupManagement.groups.last,
      );

      // If no image selected, we are done
      if (selectedImage == null) return true;

      // Upload image now that we have groupId
      final token = context!.read<AuthProvider>().lastToken;
      if (token == null) throw Exception('Not authenticated');

      final uploadResult = await uploadImageToAzure(
        scope: 'groups',
        resourceId: created.id,
        file: File(selectedImage!.path),
        accessToken: token,
      );

      // PATCH group with photo fields
      final resp = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/groups/${created.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'photoUrl': uploadResult.photoUrl,
          'photoBlobName': uploadResult.blobName,
        }),
      );
      if (resp.statusCode != 200) {
        devtools.log(
            '⚠️ Failed to update group photo: ${resp.statusCode} ${resp.body}');
        // not fatal for creation
      } else {
        // Update local state immediately for snappy UI (requires manager method)
        groupManagement.updateGroupPhoto(
          groupId: created.id,
          photoUrl: uploadResult.photoUrl,
          photoBlobName: uploadResult.blobName,
        );
      }

      return true;
    } catch (e) {
      devtools.log("Error in _createGroupAndMaybeUploadPhoto: $e");
      return false;
    }
  }

  Map<String, UserInviteStatus> _buildInvites() {
    final Map<String, UserInviteStatus> invites = {};
    userRoles.forEach((username, role) {
      if (username != currentUser!.userName) {
        invites[username] = UserInviteStatus(
          id: const Uuid().v4().substring(0, 10),
          role: role,
          invitationAnswer: null,
          sendingDate: DateTime.now(),
          attempts: 1,
          informationStatus: 'Pending',
          status: 'Unresolved',
        );
      }
    });
    return invites;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void onDataChanged(List<User> newUsers, Map<String, String> newRoles) {
    for (final user in newUsers) {
      if (!usersInGroup.any((u) => u.userName == user.userName)) {
        usersInGroup.add(user);
      }
    }
    newRoles.forEach((username, role) {
      userRoles[username] = role;
    });
    notifyListeners();
  }
}
