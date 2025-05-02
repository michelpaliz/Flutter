import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/widgets/utils/edit_group_arg.dart';
import 'package:first_project/c-frontend/routes/appRoutes.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'confirmation_dialog.dart';

/// Builds a list of dialog action widgets for a profile alert based on user permissions.
///
/// This function returns a list of [Widget]s representing actions that can be performed
/// on a group profile dialog. If the user has the necessary permissions, actions include
/// editing the group and removing it. If the user does not have permission, actions include
/// displaying the user's role and allowing them to leave the group.
///
/// Parameters:
/// - [context]: The [BuildContext] of the current widget tree.
/// - [group]: The [Group] object representing the group in question.
/// - [user]: The [User] object representing the current user.
/// - [hasPermission]: A [bool] indicating if the user has permission to edit or remove the group.
/// - [role]: A [String] representing the role of the user in the group.
/// - [userManagement]: An instance of [UserManagement] to handle user-related operations.
/// - [groupManagement]: An instance of [GroupManagement] to handle group-related operations.
///
/// Returns a list of [Widget]s containing [TextButton]s for each possible action.

List<Widget> buildProfileDialogActions(
  BuildContext context,
  Group group,
  User user,
  bool hasPermission,
  String role,
  UserManagement userManagement,
  GroupManagement groupManagement,
) {
  if (hasPermission) {
    return [
      TextButton(
        onPressed: () async {
          Navigator.of(context).pop(); // close dialog

          await Future.delayed(const Duration(milliseconds: 100));

          // Use root navigator context (safe)
          final overlayContext =
              Navigator.of(context, rootNavigator: true).context;

          // Show loading
          showDialog(
            context: overlayContext,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            final selectedGroup =
                await groupManagement.groupService.getGroupById(group.id);
            final users = await Future.wait(
              selectedGroup.userIds
                  .map((id) => userManagement.userService.getUserById(id)),
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
              SnackBar(content: Text('Error loading group: $e')),
            );
          }
        },
        child: Text(
          AppLocalizations.of(context)!.edit,
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
      ),
      TextButton(
        onPressed: () async {
          final confirm = await showConfirmationDialog(
            context,
            AppLocalizations.of(context)!.questionDeleteGroup,
          );

          if (confirm) {
            if (group.ownerId == user.id) {
              try {
                await groupManagement.groupService.deleteGroup(group.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${e.toString()}")),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text("Only the group owner can delete this group.")),
              );
            }
          }
        },
        child: Text(
          AppLocalizations.of(context)!.remove,
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
      ),
    ];
  } else {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          "Currently you are a/an $role of this group",
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
      ),
      TextButton(
        onPressed: () async {
          final confirm = await showConfirmationDialog(
            context,
            user.id == group.ownerId
                ? 'Are you sure you want to dissolve this group?'
                : 'Are you sure you want to leave this group?',
          );
          if (confirm) {
            await groupManagement.groupService.leaveGroup(user.id, group.id);
            if (context.mounted) Navigator.pop(context);
          }
        },
        child: Text(
          "Leave group",
          style: TextStyle(color: ThemeColors.getTextColor(context)),
        ),
      ),
    ];
  }
}
