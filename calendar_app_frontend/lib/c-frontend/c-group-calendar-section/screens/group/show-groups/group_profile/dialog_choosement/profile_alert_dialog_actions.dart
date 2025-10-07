import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/edit-group/widgets/utils/edit_group_arg.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/l10n/app_localizations.dart';

import 'confirmation_dialog.dart';

List<Widget> buildProfileDialogActions(
  BuildContext context,
  Group group,
  User user,
  bool hasPermission,
  String role,
  UserDomain userDomain,
  GroupDomain groupDomain,
) {
  final loc = AppLocalizations.of(context)!;
  final roleDisplay = role[0].toUpperCase() + role.substring(1);
  final colorScheme = Theme.of(context).colorScheme;

  const actionSpacing = SizedBox(height: 8);

  if (hasPermission) {
    return [
      // ✏️ Edit Button
      TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          await Future.delayed(const Duration(milliseconds: 100));

          final overlayContext =
              Navigator.of(context, rootNavigator: true).context;

          showDialog(
            context: overlayContext,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          try {
            // 🔄 Fetch fresh group via repository (no direct service)
            final selectedGroup =
                await groupDomain.groupRepository.getGroupById(group.id);

            // 👥 Load users for that group via userDomain helper
            // (avoid direct user service here)
            final users = await userDomain.getUsersForGroup(selectedGroup);

            if (overlayContext.mounted) Navigator.of(overlayContext).pop();

            Navigator.pushNamed(
              overlayContext,
              AppRoutes.editGroupData,
              arguments: EditGroupArguments(
                group: selectedGroup,
                users: users,
              ),
            );
          } catch (e) {
            if (overlayContext.mounted) Navigator.of(overlayContext).pop();
            ScaffoldMessenger.of(overlayContext).showSnackBar(
              SnackBar(content: Text('${loc.failedToEditGroup} $e')),
            );
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit),
            const SizedBox(width: 8),
            Text(loc.editGroup),
          ],
        ),
      ),

      actionSpacing,

      // 🗑️ Remove Group Button (destructive)
      TextButton(
        onPressed: () async {
          final confirm = await showConfirmationDialog(
            context,
            loc.questionDeleteGroup,
          );

          if (!confirm) return;

          if (group.ownerId == user.id) {
            try {
              // ✅ Use domain method (Management) which calls Repository internally
              final ok = await groupDomain.removeGroup(group, userDomain);
              if (ok && context.mounted) Navigator.pop(context);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.failedToEditGroup)),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${loc.failedToEditGroup} $e')),
                );
              }
            }
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.permissionDeniedInf)),
              );
            }
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_forever),
            const SizedBox(width: 8),
            Text(loc.remove),
          ],
        ),
      ),
    ];
  } else {
    return [
      // 🚫 Permission Denied Info
      TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
        ),
        child: Text(loc.permissionDeniedRole(roleDisplay)),
      ),

      actionSpacing,

      // 🚪 Leave Group Button
      TextButton(
        onPressed: () async {
          final confirm = await showConfirmationDialog(
            context,
            user.id == group.ownerId
                ? loc.questionDeleteGroup
                : loc.removeGroup,
          );
          if (!confirm) return;

          try {
            // Prefer a management wrapper if you create one; otherwise call repository
            await groupDomain.groupRepository.leaveGroup(user.id, group.id);

            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${loc.failedToEditGroup} $e')),
              );
            }
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout),
            const SizedBox(width: 8),
            Text(loc.leaveGroup),
          ],
        ),
      ),
    ];
  }
}
