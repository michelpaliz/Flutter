import 'package:flutter/material.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'role_change_logic.dart';

class RoleChangeDialogActions {
  static List<Widget> buildDialogActions(
    BuildContext context,
    String userName,
    String? selectedRole,
    Map<String, String> usersRoles,
    Map<String, UserInviteStatus> usersInvitations,
    Map<String, UserInviteStatus> usersInvitationAtFirst,
  ) {
    return [
      TextButton(
        onPressed: () {
          if (RoleChangeLogic.shouldUpdateInvitation(usersInvitations[userName])) {
            RoleChangeLogic.updateInvitationStatus(
              userName,
              usersInvitations,
              usersInvitationAtFirst,
            );
          }

          // Update user's role in the usersRoles map
          usersRoles[userName] = selectedRole!;

          Navigator.of(context).pop();
        },
        child: Text('OK'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Cancel'),
      ),
    ];
  }
}
