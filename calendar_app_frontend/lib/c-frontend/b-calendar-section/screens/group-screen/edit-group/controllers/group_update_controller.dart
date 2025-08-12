import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/notification_model/userInvitation_status.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';

class GroupUpdateController {
  final BuildContext context;
  final Group originalGroup;
  final String groupName;
  final String groupDescription;
  final String imageUrl;
  final User currentUser;
  final Map<String, String> userRoles;
  final Map<String, UserInviteStatus> usersInvitations;
  final Map<String, UserInviteStatus> usersInvitationAtFirst;
  final bool addingNewUser;

  final UserManagement userManagement;
  final GroupManagement groupManagement;
  final NotificationManagement notificationManagement;

  GroupUpdateController({
    required this.context,
    required this.originalGroup,
    required this.groupName,
    required this.groupDescription,
    required this.imageUrl,
    required this.currentUser,
    required this.userRoles,
    required this.usersInvitations,
    required this.usersInvitationAtFirst,
    required this.addingNewUser,
    required this.userManagement,
    required this.groupManagement,
    required this.notificationManagement,
  });

  Future<bool> performGroupUpdate() async {
    if (groupName.trim().isEmpty || groupDescription.trim().isEmpty) {
      _showError(AppLocalizations.of(context)!.requiredTextFields);
      return false;
    }

    try {
      // Optionally update image here if you want to upload it
      // TODO: Handle image uploading

      // Reset invitations if not updated
      final updatedInvitations = usersInvitations.isEmpty
          ? Map<String, UserInviteStatus>.from(usersInvitationAtFirst)
          : usersInvitations;

      final updatedGroup = Group(
        id: originalGroup.id,
        name: groupName,
        ownerId: currentUser.id,
        userRoles: originalGroup.userRoles,
        calendar: originalGroup.calendar,
        invitedUsers: updatedInvitations,
        userIds: originalGroup.userIds,
        createdTime: DateTime.now(),
        description: groupDescription,
        photoUrl: imageUrl,
      );

      Map<String, UserInviteStatus> newInvitations = {};

      if (addingNewUser) {
        userRoles.forEach((userName, role) {
          if (role != 'Administrator') {
            newInvitations[userName] = UserInviteStatus(
              id: originalGroup.id,
              role: role,
              invitationAnswer: null,
              sendingDate: DateTime.now(),
              attempts: 1,
              informationStatus: 'Pending',
              status: 'Unresolved',
            );
          }
        });
      }

      await groupManagement.updateGroup(updatedGroup, userManagement);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.groupEdited)),
      );

      Navigator.pop(context);
      return true;
    } catch (e) {
      print("Error updating group: $e");
      _showError(AppLocalizations.of(context)!.failedToEditGroup);
      return false;
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('OK')),
        ],
      ),
    );
  }
}
