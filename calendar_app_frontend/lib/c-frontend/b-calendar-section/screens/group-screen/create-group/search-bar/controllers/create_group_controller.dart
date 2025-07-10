import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../../../../a-models/group_model/calendar/calendar.dart';
import '../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../a-models/notification_model/userInvitation_status.dart';
import '../../../../../../../a-models/user_model/user.dart';
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
    userRoles = {
      user.userName: 'Administrator'
    }; // Set the current user as admin

    // ✅ FIX: Ensure groupManagement gets the user too
    groupManagement.setCurrentUser(user);
  }

  // This method adds a new user to the group without replacing the existing list
  void addUser(User newUser) {
    if (!usersInGroup.any((user) => user.userName == newUser.userName)) {
      usersInGroup.add(newUser); // Add the new user
      userRoles[newUser.userName] = 'Member'; // Default role for new users
      notifyListeners(); // Notify listeners to update the UI
    }
  }

  // Update the user roles when they are changed
  void onRolesUpdated(Map<String, String> updatedUserRoles) {
    userRoles = updatedUserRoles;
    notifyListeners(); // Notify listeners to update the UI
  }

  // Remove a user from the group
  void removeUser(String username) {
    if (username == currentUser?.userName) {
      _showSnackBar(AppLocalizations.of(context!)!.cannotRemoveYourself);
      return;
    }

    usersInGroup.removeWhere((u) => u.userName == username);
    userRoles.remove(username);
    notifyListeners(); // Notify listeners to update the UI
  }

  // Pick an image for the group
  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) selectedImage = image;
  }

  // Display a snackbar message
  void _showSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  // Save the group data
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

    bool result = await _createGroup();

    if (context!.mounted) {
      Navigator.of(context!).pop(); // Remove the loading dialog
      if (result) {
        _showSnackBar(AppLocalizations.of(context!)!.groupCreated);
        Navigator.of(context!).pop(); // Go back
      } else {
        _showSnackBar(AppLocalizations.of(context!)!.failedToCreateGroup);
      }
    }
  }

  // Creating the group and saving it to the database
  Future<bool> _createGroup() async {
    try {
      String groupId = const Uuid().v4().substring(0, 10);
      String calendarId = const Uuid().v4().substring(0, 10);

      User serverUser =
          await _userService.getUserByUsername(currentUser!.userName);
      List<User> allUsers = [serverUser];
      String imageURL = ""; // Add image URL if necessary

      // Prepare admin roles
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
              informationStatus: 'Pending',
              status: 'Unresolved');
        }
      });

      newGroup.invitedUsers = invites;

      bool result = await groupManagement.createGroup(newGroup, userManagement);

      devtools.log("Group creation result: $result");

      return result;
    } catch (e) {
      devtools.log("Error in _createGroup: $e");
      return false;
    }
  }

  // Show an error dialog if something goes wrong
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

  // Update the data when users or roles change
  void onDataChanged(List<User> newUsers, Map<String, String> newRoles) {
    for (final user in newUsers) {
      if (!usersInGroup.any((u) => u.userName == user.userName)) {
        usersInGroup.add(user);
      }
    }

    newRoles.forEach((username, role) {
      userRoles[username] = role; // Updates role if exists, adds if new
    });

    notifyListeners();
  }
}
