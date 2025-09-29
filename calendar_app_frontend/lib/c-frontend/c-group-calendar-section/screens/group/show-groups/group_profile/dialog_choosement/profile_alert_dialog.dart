import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/invited-user/group_role_extension.dart';
import 'package:hexora/d-stateManagement/group/group_management.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
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
  void Function(String?) updateRole, [
  bool? overridePermission,
]) {
  final user = currentUser ?? userManagement.user!;

  // 👇 Get the role of the current user in this group
  final role = group.getRoleForUser(user);

  // 👇 Determine if the user has permission to edit
  final hasPermission = overridePermission ?? role != 'Member';

  // Update the role in external state (optional usage)
  updateRole(role);

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor:
            Theme.of(context).colorScheme.surface, // 👈 Dialog background color
        content: buildProfileDialogContent(context, group),
        actions: buildProfileDialogActions(
          context,
          group,
          user,
          hasPermission,
          role,
          userManagement,
          groupManagement,
        ),
      );
    },
  );
}
