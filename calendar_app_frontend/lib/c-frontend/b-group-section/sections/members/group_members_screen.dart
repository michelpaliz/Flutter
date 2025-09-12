// c-frontend/b-calendar-section/screens/group-screen/members/group_members_screen.dart

import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/notification_model/userInvitation_status.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/utils/selected_users/filter_chips.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupMembersScreen extends StatefulWidget {
  final Group group;
  const GroupMembersScreen({super.key, required this.group});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  bool showAccepted = true;
  bool showPending = true;
  bool showNotAccepted = true;

  @override
  Widget build(BuildContext context) {
    final invited =
        widget.group.invitedUsers ?? const <String, UserInviteStatus>{};
    final roles = widget.group.userRoles; // username -> role
    final acceptedSet = widget.group.userIds.toSet(); // usernames

    // Build unified member refs (group-scope)
    final usernames = <String>{}
      ..addAll(acceptedSet)
      ..addAll(invited.keys);

    final members = usernames.map((u) {
      final inv = invited[u];
      final statusToken =
          _statusFor(u, inv, acceptedSet); // Accepted/Pending/NotAccepted
      final role = roles[u] ?? inv?.role ?? 'member';
      return MemberRef(username: u, role: role, statusToken: statusToken);
    }).toList()
      ..sort((a, b) =>
          a.username.toLowerCase().compareTo(b.username.toLowerCase()));

    // Apply chip filters
    final filtered = members.where((m) {
      switch (m.statusToken) {
        case 'Accepted':
          return showAccepted;
        case 'Pending':
          return showPending;
        case 'NotAccepted':
          return showNotAccepted;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilterChips(
              showAccepted: showAccepted,
              showPending: showPending,
              showNotWantedToJoin: showNotAccepted,
              onFilterChange: (label, selected) {
                setState(() {
                  if (label == 'Accepted') showAccepted = selected;
                  if (label == 'Pending') showPending = selected;
                  if (label == 'NotAccepted') showNotAccepted = selected;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const _EmptyHint(message: 'No members match these filters')
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _MemberRow(ref: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  String _statusFor(
    String username,
    UserInviteStatus? inv,
    Set<String> acceptedSet,
  ) {
    if (acceptedSet.contains(username)) return 'Accepted';

    final raw = (inv == null) ? '' : _extractInviteStatus(inv).toLowerCase();

    if (raw == 'accepted') return 'Accepted';
    if (raw == 'pending') return 'Pending';

    const notAcceptedTokens = [
      'rejected',
      'declined',
      'notaccepted',
      'not_accepted',
      'notwantedtojoin',
      'not_wanted_to_join',
      'cancelled',
    ];
    if (notAcceptedTokens.contains(raw)) return 'NotAccepted';

    // Invitation exists but unclear → treat as pending
    if (inv != null) return 'Pending';

    // Neither invited nor member (edge case)
    return 'NotAccepted';
  }

  String _extractInviteStatus(UserInviteStatus inv) {
    // Avoid relying on a specific getter; inspect the JSON shape.
    try {
      final m = inv.toJson(); // your class already supports toJson()
      for (final k in const [
        'status',
        'state',
        'inviteStatus',
        'invitationStatus'
      ]) {
        final v = m[k];
        if (v is String && v.isNotEmpty) return v;
      }
    } catch (_) {
      // ignore and fall through
    }
    return '';
  }
}

/// Lightweight row view model
class MemberRef {
  final String username;
  final String role;
  final String statusToken; // 'Accepted' | 'Pending' | 'NotAccepted'
  const MemberRef(
      {required this.username, required this.role, required this.statusToken});
}

class _MemberRow extends StatelessWidget {
  final MemberRef ref;
  const _MemberRow({required this.ref});

  @override
  Widget build(BuildContext context) {
    final userMgmt = context.read<UserManagement>();
    final theme = Theme.of(context);

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
            subtitle: Text('Error loading user: ${snap.error}'),
          );
        }
        final user = snap.data;
        if (user == null) {
          return ListTile(
            leading: const Icon(Icons.person_off_outlined),
            title: Text(ref.username),
            subtitle: const Text('User not found'),
          );
        }

        final titleText = (user.name.isNotEmpty ? user.name : user.userName);
        final subtitleRight = '${ref.statusToken} • ${ref.role}';

        return ListTile(
          onTap: () => _showMemberSheet(context, user, ref),
          leading: CircleAvatar(
            backgroundImage:
                (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? Text(_initials(titleText))
                : null,
          ),
          title: Text(titleText, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Row(
            children: [
              _StatusDot(token: ref.statusToken),
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
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  void _showMemberSheet(BuildContext context, User user, MemberRef ref) {
    final theme = Theme.of(context);
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
                subtitle: Text('${ref.statusToken} • ${ref.role}'),
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
                      label: const Text('View profile'),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: navigate to your profile route for this user
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.mail_outline),
                      label: const Text('Message'),
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: hook into your messaging flow
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Change role'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: show role picker & persist via backend
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: const Text('Remove from group'),
                textColor: theme.colorScheme.error,
                iconColor: theme.colorScheme.error,
                onTap: () {
                  Navigator.pop(context);
                  // TODO: confirm & remove from group + refresh
                },
              ),
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

class _StatusDot extends StatelessWidget {
  final String token; // 'Accepted' | 'Pending' | 'NotAccepted'
  const _StatusDot({required this.token});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (token) {
      case 'Accepted':
        c = Colors.green;
        break;
      case 'Pending':
        c = Colors.amber;
        break;
      default:
        c = Colors.redAccent;
    }
    return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle));
  }
}

class _EmptyHint extends StatelessWidget {
  final String message;
  const _EmptyHint({required this.message});
  @override
  Widget build(BuildContext context) {
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_outlined,
                size: 40, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Try adjusting the filters above',
                style: TextStyle(color: onSurfaceVar)),
          ],
        ),
      ),
    );
  }
}
