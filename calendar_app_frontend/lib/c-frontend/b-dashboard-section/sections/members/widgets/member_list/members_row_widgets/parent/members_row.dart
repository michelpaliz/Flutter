// c-frontend/b-calendar-section/screens/group-screen/members/widgets/members_row_widgets/parent/members_row.dart
import 'package:flutter/material.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/members_ref.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/member_list/members_row_widgets/children/badge_icon.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/member_list/members_row_widgets/children/role_chip.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/member_list/members_row_widgets/children/status_dot.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// Import your reusable widgets

class MemberRow extends StatelessWidget {
  final MemberRef ref;
  final String ownerId;
  final bool showRoleChip; // New parameter to control role chip visibility

  const MemberRow({
    super.key,
    required this.ref,
    required this.ownerId,
    this.showRoleChip = true,
  });

  bool _isOwnerRole(String? raw) {
    final s = raw?.trim().toLowerCase() ?? '';
    return s == 'owner' ||
        s == 'group_owner' ||
        s == 'creator' ||
        s == 'founder';
  }

  bool _isAdminRole(String? raw) {
    final s = raw?.trim().toLowerCase() ?? '';
    return s == 'admin' ||
        s == 'administrator' ||
        s == 'manager' ||
        s == 'moderator';
  }

  bool _isMemberRole(String? raw) {
    final s = raw?.trim().toLowerCase() ?? '';
    return s == 'member' || s.isEmpty;
  }

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

        final isOwner = (user.id == ownerId) || _isOwnerRole(ref.role);
        final isAdmin = !isOwner && _isAdminRole(ref.role);
        final isMember = !isOwner && !isAdmin && _isMemberRole(ref.role);
        final titleText = (user.name.isNotEmpty ? user.name : user.userName);

        return ListTile(
          onTap: () => _showMemberSheet(context, user, ref, isOwner, isAdmin),
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
                        : Icons.admin_panel_settings_rounded,
                    color: isOwner ? cs.primary : cs.secondary,
                    label: isOwner ? l.roleOwner : l.roleAdmin,
                  ),
                ),
            ],
          ),

          // TITLE: name + role chip inline
          title: Row(
            children: [
              Expanded(
                child: Text(
                  titleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isOwner
                      ? theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)
                      : theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 8),
              // Show role chip for members and other roles when enabled
              if (showRoleChip && !isOwner && !isAdmin)
                RoleChip(
                  label: _isMemberRole(ref.role) ? l.roleMember : ref.role,
                  color: _isMemberRole(ref.role)
                      ? Colors.grey[800]! // Black color for member role
                      : cs.tertiary,
                ),
            ],
          ),

          // SUBTITLE: status dot
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Row(
              children: [
                if (!isOwner)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: StatusDot(token: ref.statusToken),
                  ),
                if (!isOwner)
                  Expanded(
                    child: Text(
                      _getStatusText(ref.statusToken, l),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),

          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  void _showMemberSheet(
    BuildContext context,
    User user,
    MemberRef ref,
    bool isOwnerRowUser,
    bool isAdminRowUser,
  ) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final userMgmt = context.read<UserManagement>();
    final currentUserId = userMgmt.user?.id;
    final isSelf = (currentUserId != null && user.id == currentUserId);

    final titleText = (user.name.isNotEmpty ? user.name : user.userName);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TITLE ROW with inline role chip
              Row(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isOwnerRowUser
                          ? theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)
                          : theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isOwnerRowUser)
                    RoleChip(label: l.roleOwner, color: cs.primary)
                  else if (isAdminRowUser)
                    RoleChip(label: l.roleAdmin, color: cs.secondary)
                  else
                    RoleChip(
                      label: _isMemberRole(ref.role) ? l.roleMember : ref.role,
                      color: _isMemberRole(ref.role)
                          ? Colors.grey[800]! // Black color for member role
                          : cs.tertiary,
                    ),
                ],
              ),

              // STATUS below (skip for owner)
              if (!isOwnerRowUser) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      StatusDot(token: ref.statusToken),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(ref.statusToken, l),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],

              if (user.email.isNotEmpty) ...[
                const SizedBox(height: 12),
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
                        // TODO: navigate to profile route
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isSelf)
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
              if (!isOwnerRowUser) ...[
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
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(String token, AppLocalizations l) {
    switch (token) {
      case 'Accepted':
        return l.statusAccepted;
      case 'Pending':
        return l.statusPending;
      default:
        return l.statusNotAccepted;
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
