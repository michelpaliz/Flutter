import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/invited-user/group_role_extension.dart';

import 'profile_alert_dialog_actions.dart';
import 'profile_alert_dialog_content.dart';

void showProfileAlertDialog(
  BuildContext context,
  Group group,
  User owner,
  User? currentUser,
  UserDomain userDomain,
  GroupDomain groupDomain,
  void Function(String?) updateRole, [
  bool? overridePermission,
]) {
  final user = currentUser ?? userDomain.user!;

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
          userDomain,
          groupDomain,
        ),
      );
    },
  );
}
