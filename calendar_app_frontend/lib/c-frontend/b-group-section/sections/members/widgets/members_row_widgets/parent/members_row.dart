import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/b-group-section/sections/members/models/members_ref.dart';
import 'package:calendar_app_frontend/c-frontend/b-group-section/sections/members/widgets/members_row_widgets/children/badge_icon.dart';
import 'package:calendar_app_frontend/c-frontend/b-group-section/sections/members/widgets/members_row_widgets/children/role_chip.dart';
import 'package:calendar_app_frontend/c-frontend/b-group-section/sections/members/widgets/members_row_widgets/children/status_dot.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberRow extends StatelessWidget {
  final MemberRef ref;
  final String ownerId;
  const MemberRow({super.key, required this.ref, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    final userMgmt = context.read<UserManagement>();
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return FutureBuilder<User?>(
      future: userMgmt.userService.getUserBySelector(ref.username),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircleAvatar(
              child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            title: SizedBox(height: 14, child: LinearProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return ListTile(
            leading: const Icon(Icons.error_outline),
            title: Text(ref.username),
            subtitle: Text(l.errorLoadingUser('${snap.error}')),
          );
        }
        final user = snap.data;
        if (user == null) {
          return ListTile(
            leading: const Icon(Icons.person_off_outlined),
            title: Text(ref.username),
            subtitle: Text(l.userNotFound),
          );
        }

        final isOwner = user.id == ownerId;
        final isAdmin = !isOwner && ref.role.toLowerCase() == 'admin';

        final titleText = (user.name.isNotEmpty ? user.name : user.userName);
        final statusLabel = _statusLabel(context, ref.statusToken);
        final roleLabel = _roleLabel(context, ref.role);
        final subtitleRight = '$statusLabel • $roleLabel';

        return ListTile(
          onTap: () => _showMemberSheet(context, user, ref),
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                backgroundImage:
                    (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                        ? NetworkImage(user.photoUrl!)
                        : null,
                child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                    ? Text(_initials(titleText))
                    : null,
              ),
              if (isOwner || isAdmin)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: BadgeIcon(
                    icon: isOwner
                        ? Icons.workspace_premium_rounded
                        : Icons.admin_panel_settings_rounded, // ← replaced
                    color: isOwner ? cs.primary : cs.secondary,
                    label: isOwner ? l.roleOwner : l.roleAdmin,
                  ),
                ),
            ],
          ),
          title: Text(
            titleText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isOwner
                ? theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)
                : null,
          ),
          subtitle: Row(
            children: [
              StatusDot(token: ref.statusToken),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  subtitleRight,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwner)
                RoleChip(label: l.roleOwner, color: cs.primary)
              else if (isAdmin)
                RoleChip(label: l.roleAdmin, color: cs.secondary),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right),
            ],
          ),
        );
      },
    );
  }

  void _showMemberSheet(BuildContext context, User user, MemberRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final titleText = (user.name.isNotEmpty ? user.name : user.userName);
    final statusLabel = _statusLabel(context, ref.statusToken);
    final roleLabel = _roleLabel(context, ref.role);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage:
                      (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                          ? NetworkImage(user.photoUrl!)
                          : null,
                  child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                      ? Text(_initials(titleText))
                      : null,
                ),
                title: Text(titleText),
                subtitle: Text('$statusLabel • $roleLabel'),
              ),
              if (user.email.isNotEmpty) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(user.email, style: theme.textTheme.bodySmall),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.info_outline),
                      label: Text(l.viewProfile),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: navigate to profile
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.mail_outline),
                      label: Text(l.message),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: messaging flow
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: Text(l.changeRole),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: show role picker & persist
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: Text(l.removeFromGroup),
                textColor: theme.colorScheme.error,
                iconColor: theme.colorScheme.error,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: confirm & remove
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context, String token) {
    final l = AppLocalizations.of(context)!;
    switch (token) {
      case 'Accepted':
        return l.statusAccepted;
      case 'Pending':
        return l.statusPending;
      default:
        return l.statusNotAccepted;
    }
  }

  String _roleLabel(BuildContext context, String roleRaw) {
    final l = AppLocalizations.of(context)!;
    switch (roleRaw.toLowerCase()) {
      case 'owner':
        return l.roleOwner;
      case 'admin':
        return l.roleAdmin;
      case 'member':
        return l.roleMember;
      default:
        return roleRaw;
    }
  }

  String _initials(String text) {
    final t = text.trim();
    if (t.isEmpty) return '?';
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
