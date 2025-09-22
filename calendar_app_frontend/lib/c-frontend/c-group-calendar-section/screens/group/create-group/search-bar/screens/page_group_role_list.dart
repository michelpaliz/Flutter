import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../../a-models/user_model/user.dart';

class PagedGroupRoleList extends StatefulWidget {
  final Map<String, String> userRoles; // username -> role
  final Map<String, User> membersByUsername; // username -> User (cached)
  final List<String> assignableRoles;
  final bool Function(String username) canEditRole;
  final void Function(String username, String newRole) setRole;
  final void Function(String username)? onRemoveUser;

  const PagedGroupRoleList({
    super.key,
    required this.userRoles,
    required this.membersByUsername,
    required this.assignableRoles,
    required this.canEditRole,
    required this.setRole,
    this.onRemoveUser,
  });

  @override
  State<PagedGroupRoleList> createState() => _PagedGroupRoleListState();
}

class _PagedGroupRoleListState extends State<PagedGroupRoleList> {
  static const int _pageSize = 20; // with 2 users, no "Load more" will appear
  int _visible = _pageSize;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // ---- admin-first sort (then alphabetical) ----
    int priority(String u) => (widget.userRoles[u] == 'Administrator') ? 0 : 1;

    final usernames = widget.userRoles.keys.toList()
      ..sort((a, b) {
        final p = priority(a).compareTo(priority(b));
        return p != 0 ? p : a.toLowerCase().compareTo(b.toLowerCase());
      });

    final total = usernames.length;
    final visible = _visible.clamp(0, total);

    if (total == 0) return Text(loc.noUserRolesAvailable);

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visible,
          itemBuilder: (_, i) {
            final username = usernames[i];
            final role = widget.userRoles[username] ?? 'Member';
            final user = widget.membersByUsername[username];
            final editable = widget.canEditRole(username);

            return _memberTile(
              context: context,
              userName: username,
              role: role,
              user: user,
              editable: editable,
              roles: widget.assignableRoles,
              onRoleChanged: (newRole) => widget.setRole(username, newRole),
              onRemove:
                  editable ? () => (widget.onRemoveUser?.call(username)) : null,
            );
          },
        ),
        if (visible < total)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.expand_more),
              label: Text(
                // localize if you add a key; string kept simple for now
                'Load ${(_pageSize).clamp(0, total - visible)} more',
              ),
              onPressed: () => setState(() => _visible += _pageSize),
            ),
          ),
      ],
    );
  }

  Widget _memberTile({
    required BuildContext context,
    required String userName,
    required String role,
    required User? user,
    required bool editable,
    required List<String> roles,
    required ValueChanged<String> onRoleChanged,
    required VoidCallback? onRemove,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: CircleAvatar(
            radius: 20, // tighter
            backgroundImage: (user?.photoUrl?.isNotEmpty ?? false)
                ? NetworkImage(user!.photoUrl!)
                : null,
            child: (user?.photoUrl?.isEmpty ?? true)
                ? Text(userName.isNotEmpty ? userName[0].toUpperCase() : '?')
                : null,
          ),
          title: Text(
            (user?.name?.isNotEmpty ?? false) ? user!.name : userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(
            userName, // or user?.email ?? userName
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: (textColor ?? Colors.black).withOpacity(0.6),
            ),
          ),
          trailing: SizedBox(
            width: 180,
            child: Align(
              alignment: Alignment.centerRight,
              child: editable
                  ? _RoleSelector(
                      value: role,
                      options:
                          {...roles, role}.toList(), // ensure current present
                      onChanged: onRoleChanged,
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _localizedRole(context, role),
                            style: TextStyle(
                              color: scheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified_user,
                            color: Colors.green, size: 20),
                      ],
                    ),
            ),
          ),
          onLongPress: onRemove,
        ),
        const Divider(height: 1),
      ],
    );
  }
}

// ---- role selector with localized labels ----
class _RoleSelector extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _RoleSelector({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(10),
          items: options.map((r) {
            final label = _localizedRole(context, r);
            return DropdownMenuItem<String>(value: r, child: Text(label));
          }).toList(),
          onChanged: (v) {
            if (v != null && v != value) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ---- localization helper ----
String _localizedRole(BuildContext context, String role) {
  final loc = AppLocalizations.of(context)!;
  switch (role.toLowerCase()) {
    case 'administrator':
      return loc.administrator;
    case 'co-administrator':
    case 'coadministrator':
      return loc.coAdministrator; // add this key in your ARB if missing
    default:
      return loc.member;
  }
}
