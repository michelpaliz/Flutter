import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/d-stateManagement/group/group_management.dart';
import 'package:hexora/d-stateManagement/notification/notification_management.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
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

  Future<bool> performUserRemoval(
    String fetchedUserName,
    bool? invitationStatus,
    bool isNewUser,
  ) async {
    try {
      final fetchedUser = usersInGroup.firstWhere(
        (user) => user.userName.toLowerCase() == fetchedUserName.toLowerCase(),
        orElse: () => throw Exception("User not found"),
      );

      if (isNewUser) {
        _handleNewUserRemoval(fetchedUser.userName);
        return true;
      } else {
        return await _handleExistingUserRemoval(fetchedUser, invitationStatus);
      }
    } catch (e) {
      print("Error removing user: $e");
      return false;
    }
  }

  void _handleNewUserRemoval(String fetchedUserName) {
    usersInGroup.removeWhere(
      (user) => user.userName.toLowerCase() == fetchedUserName.toLowerCase(),
    );
    usersInvitations.remove(fetchedUserName);
    usersRoles.remove(fetchedUserName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'User $fetchedUserName removed before sending any invitation.',
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  Future<bool> _handleExistingUserRemoval(
    User fetchedUser,
    bool? invitationStatus,
  ) async {
    // Check if the invitation is pending or denied
    if (invitationStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User ${fetchedUser.userName} has a pending invitation and cannot be removed until the invitation is answered.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return false;
    }

    if (invitationStatus == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User ${fetchedUser.userName} declined the invitation. Record retained.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      return true;
    }

    try {
      // ✅ Call backend to remove user (backend handles group update + notifications)
      final success = await groupManagement.groupService.removeUserInGroup(
        fetchedUser.id,
        group.id,
      );

      if (success) {
        // ✅ Refresh group state from backend
        final updatedGroup = await groupManagement.groupService.getGroupById(
          group.id,
        );
        groupManagement.currentGroup = updatedGroup;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User ${fetchedUser.userName} removed from the group.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to remove user ${fetchedUser.userName} from the server.',
            ),
            duration: Duration(seconds: 5),
          ),
        );
        return false;
      }
    } catch (e) {
      print("❌ Exception removing user: $e");
      return false;
    }
  }
}
