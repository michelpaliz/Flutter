import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/edit-group/widgets/utils/edit_group_arg.dart';
import 'package:calendar_app_frontend/c-frontend/routes/appRoutes.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';

import 'confirmation_dialog.dart';

List<Widget> buildProfileDialogActions(
  BuildContext context,
  Group group,
  User user,
  bool hasPermission,
  String role,
  UserManagement userManagement,
  GroupManagement groupManagement,
) {
  final loc = AppLocalizations.of(context)!;
  final roleDisplay =
      role[0].toUpperCase() + role.substring(1); // Capitalize role

  if (hasPermission) {
    return [
      TextButton(
        onPressed: () async {
          Navigator.of(context).pop(); // close dialog

          await Future.delayed(const Duration(milliseconds: 100));

          final overlayContext = Navigator.of(
            context,
            rootNavigator: true,
          ).context;

          showDialog(
            context: overlayContext,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final selectedGroup =
                await groupManagement.groupService.getGroupById(group.id);
            final users = await Future.wait(
              selectedGroup.userIds.map(
                (id) => userManagement.userService.getUserById(id),
              ),
            );

            if (overlayContext.mounted)
              Navigator.of(overlayContext).pop(); // close loader

            Navigator.pushNamed(
              overlayContext,
              AppRoutes.editGroupData,
              arguments: EditGroupArguments(group: selectedGroup, users: users),
            );
          } catch (e) {
            if (overlayContext.mounted)
              Navigator.of(overlayContext).pop(); // close loader
            ScaffoldMessenger.of(overlayContext).showSnackBar(
              SnackBar(content: Text('${loc.failedToEditGroup} $e')),
            );
          }
        },
        child: Text(
          loc.editGroup,
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
      ),
      TextButton(
        onPressed: () async {
          final confirm = await showConfirmationDialog(
            context,
            loc.questionDeleteGroup,
          );

          if (confirm) {
            if (group.ownerId == user.id) {
              try {
                await groupManagement.groupService.deleteGroup(group.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${loc.failedToEditGroup} $e')),
                );
              }
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(loc.permissionDeniedInf)));
            }
          }
        },
        child: Text(
          loc.remove,
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
      ),
    ];
  } else {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          loc.permissionDeniedRole(roleDisplay),
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
      ),
      TextButton(
        onPressed: () async {
          final confirm = await showConfirmationDialog(
            context,
            user.id == group.ownerId
                ? loc.questionDeleteGroup
                : loc.removeGroup,
          );
          if (confirm) {
            await groupManagement.groupService.leaveGroup(user.id, group.id);
            if (context.mounted) Navigator.pop(context);
          }
        },
        child: Text(
          loc.leaveGroup,
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
      ),
    ];
  }
}
