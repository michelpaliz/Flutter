import 'dart:convert'; // ✅ NEW
import 'dart:developer' as devtools show log;
import 'dart:io'; // ✅ NEW

import 'package:flutter/material.dart';
import 'package:hexora/b-backend/api/blobUploader/blob_uploader.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:http/http.dart' as http; // ✅ NEW
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart'; // ✅ NEW
import 'package:uuid/uuid.dart';

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
  // Cache full User models by userName so the UI doesn't need per-row HTTP calls
  final Map<String, User> membersByUsername = {};

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

    usersInGroup = [user];
    userRoles = {user.userName: 'Administrator'};

    // NEW: seed cache
    membersByUsername[user.userName] = user;

    groupManagement.setCurrentUser(user);
    // notifyListeners(); // optional if you want immediate rebuild
  }

  void addMember(User newUser) {
    if (!usersInGroup.any((u) => u.userName == newUser.userName)) {
      usersInGroup.add(newUser);
    }
    userRoles[newUser.userName] ??= 'Member';

    // NEW: cache the model
    membersByUsername[newUser.userName] = newUser;
    notifyListeners();
  }

  void removeUser(String username) {
    if (username == currentUser?.userName) {
      _showSnackBar(AppLocalizations.of(context!)!.cannotRemoveYourself);
      return;
    }
    usersInGroup.removeWhere((u) => u.userName == username);
    userRoles.remove(username);

    // NEW: remove from cache
    membersByUsername.remove(username);
    notifyListeners();
  }

  void onRolesUpdated(Map<String, String> updatedUserRoles) {
    userRoles = updatedUserRoles;
    notifyListeners();
  }

// Call controller.hydrateMembers(existingMembersFromApi); after you fetch the group details.
  void hydrateMembers(List<User> users) {
    for (final u in users) {
      membersByUsername[u.userName] = u;
      userRoles[u.userName] = userRoles[u.userName] ?? 'Member';
      if (!usersInGroup.any((x) => x.userName == u.userName)) {
        usersInGroup.add(u);
      }
    }
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


  // ✅ Create group first, then (optionally) upload image and commit { blobName }.
  Future<bool> _createGroupAndMaybeUploadPhoto() async {
    try {
      // 1) Build payload and create the group (without photo)

      final adminRoles = {currentUser!.userName: 'Administrator'};
// Build the group (no calendar field)
      final newGroup = Group(
        id: '',
        name: groupName,
        ownerId: currentUser!.id,
        userRoles: adminRoles,
        userIds: [currentUser!.id],
        createdTime: DateTime.now(),
        description: groupDescription,
        photoUrl: '',
        photoBlobName: null,
        invitedUsers: _buildInvites(),
        defaultCalendarId: null, // backend will set it
        defaultCalendar: null, // backend may return a snapshot
      );

// Call your manager/service with the calendar type
      // Just await without storing the result
      await groupManagement.createGroup(
        newGroup,
        userManagement,
      );

      // Retrieve the created group (adjust per your app’s logic if needed)
      final created = groupManagement.groups.lastWhere(
        (g) => g.name == newGroup.name && g.ownerId == newGroup.ownerId,
        orElse: () => groupManagement.groups.last,
      );

      // 2) If no image was picked, we're done
      if (selectedImage == null) return true;

      // 3) Upload image to Azure (scope: groups, resourceId = created.id)
      final token = context!.read<AuthProvider>().lastToken;
      if (token == null) throw Exception('Not authenticated');

      final uploadResult = await uploadImageToAzure(
        scope: 'groups',
        resourceId: created.id,
        file: File(selectedImage!.path),
        accessToken: token,
        // mimeType defaults to 'image/jpeg'; helper uses 'versioned'
      );

      // 4) Commit photo to backend with only blobName
      final resp = await http.patch(
        Uri.parse('${ApiConstants.baseUrl}/groups/${created.id}/photo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'blobName': uploadResult.blobName}),
      );

      if (resp.statusCode == 200) {
        // 5) Update local state / managers for immediate UI refresh
        groupManagement.updateGroupPhoto(
          groupId: created.id,
          photoUrl: uploadResult.photoUrl, // CDN (public) or read-SAS (private)
          photoBlobName: uploadResult.blobName,
        );
        return true;
      } else {
        devtools.log(
          '⚠️ Failed to commit group photo: ${resp.statusCode} ${resp.body}',
        );
        // Not fatal to group creation; return true so UX proceeds
        return true;
      }
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

  /// Search users by name, username, or email.
  /// Backend is expected to expose: GET /users/search?q=...&limit=...
  Future<List<User>> searchUsers(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    try {
      // If you require auth, include the bearer token
      final token = context?.read<AuthProvider>().lastToken;

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/users/search'
        '?q=${Uri.encodeQueryComponent(q)}&limit=$limit',
      );

      final resp = await http.get(
        uri,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is List) {
          return decoded.map<User>((e) => User.fromJson(e)).toList();
        }
        // if backend wraps the list: { items: [...] }
        if (decoded is Map && decoded['items'] is List) {
          final items = decoded['items'] as List;
          return items.map<User>((e) => User.fromJson(e)).toList();
        }
        return [];
      }

      if (resp.statusCode == 404) {
        // no matches
        return [];
      }

      devtools.log('searchUsers failed: ${resp.statusCode} ${resp.body}');
      throw Exception('Failed to search users');
    } catch (e) {
      devtools.log('searchUsers error: $e');
      return [];
    }
  }

  /// Fetch groups for the given user and return the up-to-date list.
  /// Uses GroupManagement.fetchAndInitializeGroups internally.
  static Future<List<Group>> fetchGroups(
    User? user,
    GroupManagement groupManager,
  ) async {
    if (user == null) {
      devtools.log('⚠️ GroupController.fetchGroups: user is null, aborting.');
      return const [];
    }

    try {
      devtools.log(
        '📥 GroupController.fetchGroups: user=${user.userName} (${user.id}) '
        'groupIds=${user.groupIds}',
      );

      await groupManager.fetchAndInitializeGroups(user.groupIds);

      // Return the manager’s canonical list
      final groups = List<Group>.from(groupManager.groups);
      devtools.log(
          '✅ GroupController.fetchGroups: loaded ${groups.length} groups.');
      return groups;
    } catch (e) {
      devtools.log('❌ GroupController.fetchGroups error: $e');
      return const [];
    }
  }

  // Available roles a creator can assign (you can localize labels in the UI)
  final List<String> assignableRoles = const ['Member', 'Co-Administrator'];

  bool _isCurrentUser(String username) => currentUser?.userName == username;

  /// Can the role of this username be edited?
  bool canEditRole(String username) {
    // You can refine this (e.g., also lock the creator/owner or anyone with Administrator)
    return !_isCurrentUser(username) &&
        (userRoles[username] != 'Administrator');
  }

  /// Change a user's role and notify listeners.
  void setRole(String username, String newRole) {
    if (!userRoles.containsKey(username)) return;
    if (!canEditRole(username)) return;
    if (userRoles[username] == newRole) return;
    userRoles[username] = newRole;
    notifyListeners();
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
