// c-frontend/b-calendar-section/screens/group-screen/members/widgets/members_row_widgets/parent/members_row.dart
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/b-dashboard-section/sections/members/models/members_ref.dart';

import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberRow extends StatelessWidget {
  final MemberRef ref;
  final String ownerId;
  const MemberRow({super.key, required this.ref, required this.ownerId});

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
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              if (isOwner)
                _RoleChip(label: l.roleOwner, color: cs.primary)
              else if (isAdmin)
                _RoleChip(label: l.roleAdmin, color: cs.secondary),
            ],
          ),

          // SUBTITLE: status chip (owners hide it)
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (!isOwner) _StatusChip(token: ref.statusToken),
                if (!isOwner &&
                    !isAdmin &&
                    ref.role.trim().isNotEmpty &&
                    ref.role.toLowerCase() != 'member')
                  _RoleChip(label: ref.role, color: cs.tertiary),
              ],
            ),
          ),

          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  // ---------- Bottom sheet updated: title row includes role chip ----------
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
                    _RoleChip(label: l.roleOwner, color: cs.primary)
                  else if (isAdminRowUser)
                    _RoleChip(label: l.roleAdmin, color: cs.secondary)
                  else if (ref.role.trim().isNotEmpty &&
                      ref.role.toLowerCase() != 'member')
                    _RoleChip(label: ref.role, color: cs.tertiary),
                ],
              ),

              // STATUS chip below (skip for owner)
              if (!isOwnerRowUser) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(token: ref.statusToken),
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

  String _initials(String text) {
    final t = text.trim();
    if (t.isEmpty) return '?';
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

// ---- small helpers ---------------------------------------------------------

class _StatusChip extends StatelessWidget {
  final String token; // 'Accepted' | 'Pending' | 'NotAccepted'
  const _StatusChip({required this.token});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    late final String label;
    late final Color color;

    switch (token) {
      case 'Accepted':
        label = l.statusAccepted;
        color = const Color(0xFF16A34A); // green-600
        break;
      case 'Pending':
        label = l.statusPending;
        color = const Color(0xFFF59E0B); // amber-600
        break;
      default:
        label = l.statusNotAccepted;
        color = const Color(0xFFDC2626); // red-600
        break;
    }

    final on = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: on, fontWeight: FontWeight.w700)),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final Color color;
  const _RoleChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final on = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: on, fontWeight: FontWeight.w700)),
    );
  }
}

class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double size;
  const BadgeIcon(
      {super.key,
      required this.icon,
      required this.color,
      required this.label,
      this.size = 14});

  @override
  Widget build(BuildContext context) {
    final on = ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final child = Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))
        ],
      ).copyWith(color: color),
      child: Icon(icon, size: size, color: on),
    );
    return Tooltip(
        message: label, child: Semantics(label: label, child: child));
  }
}
