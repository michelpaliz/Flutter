import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../a-models/group_model/calendar/calendar.dart';
import '../../../../a-models/group_model/group/group.dart';
import '../../../../a-models/notification_model/userInvitation_status.dart';
import '../../../../a-models/user_model/user.dart';
import '../../../../b-backend/auth/node_services/user_services.dart';
import '../../../../d-stateManagement/group_management.dart';
import '../../../../d-stateManagement/notification_management.dart';
import '../../../../d-stateManagement/user_management.dart';

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
  List<User> usersInGroup = [];
  Map<String, String> userRoles = {};

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
  }

  void updateUserInGroup(List<User> updatedData) {
    usersInGroup = updatedData;
  }

  void onRolesUpdated(Map<String, String> updatedUserRoles) {
    userRoles = updatedUserRoles;
  }

  void removeUser(String username) {
    if (username == currentUser?.userName) {
      _showSnackBar(AppLocalizations.of(context!)!.cannotRemoveYourself);
      return;
    }

    usersInGroup.removeWhere((u) => u.userName == username);
    userRoles.remove(username);
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) selectedImage = image;
  }

  void _showSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> saveGroup() async {
    if (groupName.trim().isEmpty || groupDescription.trim().isEmpty) {
      _showErrorDialog(AppLocalizations.of(context!)!.requiredTextFields);
      return;
    }

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    bool result = await _createGroup();

    if (context!.mounted) {
      Navigator.of(context!).pop(); // remove loading dialog
      if (result) {
        _showSnackBar(AppLocalizations.of(context!)!.groupCreated);
        Navigator.of(context!).pop(); // go back
      } else {
        _showSnackBar(AppLocalizations.of(context!)!.failedToCreateGroup);
      }
    }
  }

  Future<bool> _createGroup() async {
    try {
      String groupId = const Uuid().v4().substring(0, 10);
      String calendarId = const Uuid().v4().substring(0, 10);

      User serverUser =
          await _userService.getUserByUsername(currentUser!.userName);
      List<User> allUsers = [serverUser];
      String imageURL = "";

      // If you're uploading image via a service, use this:
      // if (selectedImage != null) {
      //   imageURL = await Utilities.pickAndUploadImageGroup(groupId, selectedImage);
      // }

      Map<String, String> adminRoles = {currentUser!.userName: 'Administrator'};

      Group newGroup = Group(
        id: groupId,
        name: groupName,
        ownerId: currentUser!.id,
        userRoles: adminRoles,
        calendar: Calendar(calendarId, groupName),
        userIds: [currentUser!.id],
        invitedUsers: null,
        createdTime: DateTime.now(),
        description: groupDescription,
        photo: imageURL,
      );

      // Prepare invitations (skip admin user)
      Map<String, UserInviteStatus> invites = {};
      userRoles.forEach((username, role) {
        if (username != currentUser!.userName) {
          invites[username] = UserInviteStatus(
            id: groupId,
            role: role,
            invitationAnswer: null,
            sendingDate: DateTime.now(),
            attempts: 1,
          );
        }
      });

      newGroup.invitedUsers = invites;

      bool result = await groupManagement.addGroup(
        newGroup,
        notificationManagement,
        userManagement,
        {},
      );

      devtools.log("Group creation result: $result");

      return result;
    } catch (e) {
      devtools.log("Error in _createGroup: $e");
      return false;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context!,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
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

  void onDataChanged(List<User> users, Map<String, String> roles) {
    usersInGroup = users;
    userRoles = roles;
    notifyListeners(); // ✅ This triggers UI updates like the role list
  }
}
