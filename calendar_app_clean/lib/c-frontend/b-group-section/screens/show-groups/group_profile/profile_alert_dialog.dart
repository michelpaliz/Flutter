import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';

import 'profile_alert_dialog_actions.dart';
import 'profile_alert_dialog_content.dart';

void showProfileAlertDialog(
    BuildContext context,
    Group group,
    User owner,
    User? currentUser,
    UserManagement userManagement,
    GroupManagement groupManagement,
    void Function(String?) updateRole,
    [bool? overridePermission]) {
  final user = currentUser ?? userManagement.user!;

  // 👇 Get the role of the current user in this group
  final role = group.userRoles[user.userName] ?? 'Member';

  // 👇 Determine if the user has permission to edit
  final hasPermission = overridePermission ?? role != 'Member';

  // Update the role in external state (optional usage)
  updateRole(role);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: buildProfileDialogContent(context, group),
        actions: buildProfileDialogActions(
          context,
          group,
          user,
          hasPermission, // 👈 Apply permission logic
          role,
          userManagement,
          groupManagement,
        ),
      );
    },
  );
}
