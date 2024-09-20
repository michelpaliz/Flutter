import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/frontend/event-logic/edit_logic/widgets/selected_users/invitation_functions/role_change_dialog_actions.dart';
import 'package:first_project/frontend/event-logic/edit_logic/widgets/selected_users/invitation_functions/role_change_dialog_content.dart';
import 'package:flutter/material.dart';


class RoleChangeDialog {
  static void show(
    BuildContext context,
    String userName,
    String? selectedRole,
    UserInviteStatus? userInviteStatus,
    Function(String?) onRoleSelected,
    Map<String, String> usersRoles, // map to store user roles
    Map<String, UserInviteStatus> usersInvitations, // map for user invitations
    Map<String, UserInviteStatus> usersInvitationAtFirst, // secondary map for invitation updates
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Role for $userName'),
          content: RoleChangeDialogContent(
            userName: userName,
            selectedRole: selectedRole,
            userInviteStatus: userInviteStatus,
            onRoleSelected: onRoleSelected,
          ),
          actions: RoleChangeDialogActions.buildDialogActions(
            context,
            userName,
            selectedRole,
            usersRoles,
            usersInvitations,
            usersInvitationAtFirst,
          ),
        );
      },
    );
  }
}
