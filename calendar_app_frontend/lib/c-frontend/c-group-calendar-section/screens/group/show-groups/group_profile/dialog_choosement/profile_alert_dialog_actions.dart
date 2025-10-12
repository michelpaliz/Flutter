import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
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
      // NEW: Owner can delete only if all other members were removed first.
      TextButton(
        onPressed: () async {
          try {
            final overlayContext =
                Navigator.of(context, rootNavigator: true).context;

            showDialog(
              context: overlayContext,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            // 1) Get the latest group snapshot
            final freshGroup =
                await groupDomain.groupRepository.getGroupById(group.id);

            // 2) Get current members
            final members = await userDomain.getUsersForGroup(freshGroup);

            if (overlayContext.mounted) Navigator.of(overlayContext).pop();

            // Must be owner to delete
            if (freshGroup.ownerId != user.id) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(loc.permissionDeniedInf)),
                );
              }
              return;
            }

            // Rule: owner can delete the group only if ALL other members were removed
            final nonOwnerMembers =
                members.where((m) => m.id != freshGroup.ownerId).toList();

            if (nonOwnerMembers.isNotEmpty) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      // Prefer localization key if exists; fallback text otherwise.
                      (loc.removeMembersFirst),
                    ),
                  ),
                );
              }
              return;
            }

            // Confirm deletion now that only the owner remains
            final confirm = await showConfirmationDialog(
              context,
              loc.questionDeleteGroup,
            );
            if (!confirm) return;

            // Proceed with delete via domain
            try {
              final ok = await groupDomain.removeGroup(freshGroup, userDomain);
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
          } catch (e) {
            // Fetch/members load failed
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
      // NEW: Any non-owner member can leave anytime.
      TextButton(
        onPressed: () async {
          final confirm = await showConfirmationDialog(
            context,
            // Use a specific "leave group" prompt if available; fallback to clear text.
            (loc.leaveGroupQuestion),
          );
          if (!confirm) return;

          try {
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
