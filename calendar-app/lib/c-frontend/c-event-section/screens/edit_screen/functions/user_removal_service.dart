import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/utilities/notification_formats.dart';
import 'package:flutter/material.dart';

class UserRemovalService {
  final BuildContext context;
  final List<User> usersInGroup;
  final Map<String, UserInviteStatus> usersInvitations;
  final Map<String, String> usersRoles;
  final GroupManagement groupManagement;
  final UserManagement userManagement;
  final NotificationManagement notificationManagement;
  final Group group;

  UserRemovalService({
    required this.context,
    required this.usersInGroup,
    required this.usersInvitations,
    required this.usersRoles,
    required this.groupManagement,
    required this.userManagement,
    required this.notificationManagement,
    required this.group,
  });

  // Main function to handle user removal with a return value indicating success/failure
  Future<bool> performUserRemoval(
      String fetchedUserName, bool? invitationStatus, bool isNewUser) async {
    try {
      // Check if the user is in the group
      final fetchedUser = usersInGroup.firstWhere(
        (user) => user.userName.toLowerCase() == fetchedUserName.toLowerCase(),
        orElse: () => throw Exception("User not found"),
      );

      if (isNewUser) {
        _handleNewUserRemoval(fetchedUser.userName);
        return true; // Indicating success for new user removal
      } else {
        return await _handleExistingUserRemoval(fetchedUser, invitationStatus);
      }
    } catch (e) {
      // If there's any error, such as the user not being found
      print("Error removing user: $e");
      return false; // Indicating failure
    }
  }

  // Function to handle new user removal (users who haven't accepted the invitation yet)
  void _handleNewUserRemoval(String fetchedUserName) {
    usersInGroup.removeWhere(
      (user) => user.userName.toLowerCase() == fetchedUserName.toLowerCase(),
    );
    usersInvitations.remove(fetchedUserName);
    usersRoles.remove(fetchedUserName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'User $fetchedUserName removed before sending any invitation.'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  // Function to handle existing user removal (users who are already part of the group)
  Future<bool> _handleExistingUserRemoval(
      User fetchedUser, bool? invitationStatus) async {
    if (usersInGroup.any((user) =>
        user.userName.toLowerCase() == fetchedUser.userName.toLowerCase())) {
      // Remove user from local lists
      usersRoles.remove(fetchedUser.userName);
      usersInGroup.removeWhere((user) =>
          user.userName.toLowerCase() == fetchedUser.userName.toLowerCase());
      usersInvitations.remove(fetchedUser.userName);

      // Remove user from server
      bool result = await groupManagement.groupService.removeUserInGroup(
        fetchedUser.id,
        group.id,
      );

      if (result) {
        // Fetch admin user for notification purposes
        User admin =
            await userManagement.userService.getUserById(fetchedUser.id);

        // Prepare and send notifications to admin and member
        NotificationFormats notificationFormats = NotificationFormats();
        NotificationUser ntfAdmin =
            notificationFormats.userRemovedFromGroup(group, fetchedUser, admin);
        NotificationUser ntfMember =
            notificationFormats.notifyUserRemoval(group, fetchedUser, admin);

        await notificationManagement.addNotificationToDB(
            ntfAdmin, userManagement);
        await notificationManagement.addNotificationToDB(
            ntfMember, userManagement);

        // Notify via Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'User ${fetchedUser.userName} removed from the group and their invitation record has been deleted.'),
            duration: Duration(seconds: 5),
          ),
        );
        return true; // Indicating success
      } else {
        // Handle failure to remove user from the server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to remove user ${fetchedUser.userName} from the server.'),
            duration: Duration(seconds: 5),
          ),
        );
        return false; // Indicating failure
      }
    } else if (invitationStatus == null) {
      // Pending invite case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User ${fetchedUser.userName} has a pending invitation and cannot be removed until the invitation is answered.'),
          duration: Duration(seconds: 5),
        ),
      );
      return false; // Cannot remove due to pending invite
    } else if (invitationStatus == false) {
      // Invite declined case
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User ${fetchedUser.userName} declined the invitation, but the invitation record is retained.'),
          duration: Duration(seconds: 5),
        ),
      );
      return true; // Invite declined, but action still considered successful
    }

    return false; // In case any unexpected condition occurs
  }
}
