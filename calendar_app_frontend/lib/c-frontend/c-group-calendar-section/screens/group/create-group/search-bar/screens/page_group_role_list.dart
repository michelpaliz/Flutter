import 'package:flutter/material.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/l10n/app_localizations.dart';

class PagedGroupRoleList extends StatefulWidget {
  final Map<String, String> userRoles; // userId -> role
  final Map<String, User> membersById; // userId -> User
  final List<String> assignableRoles;
  final bool Function(String userId) canEditRole;
  final void Function(String userId, String newRole) setRole;
  final void Function(String userId)? onRemoveUser;

  const PagedGroupRoleList({
    super.key,
    required this.userRoles,
    required this.membersById,
    required this.assignableRoles,
    required this.canEditRole,
    required this.setRole,
    this.onRemoveUser,
  });

  @override
  State<PagedGroupRoleList> createState() => _PagedGroupRoleListState();
}

class _PagedGroupRoleListState extends State<PagedGroupRoleList> {
  static const int _pageSize = 20;
  int _visible = _pageSize;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Sort by role priority (owner/admin/co-admin/member)
    int priority(String role) {
      switch (role.toLowerCase()) {
        case 'owner':
          return 0;
        case 'admin':
          return 1;
        case 'co-admin':
          return 2;
        default:
          return 3;
      }
    }

    // Sort users by role priority, then by name
    final userIds = widget.userRoles.keys.toList()
      ..sort((a, b) {
        final roleA = widget.userRoles[a] ?? 'member';
        final roleB = widget.userRoles[b] ?? 'member';
        final p = priority(roleA).compareTo(priority(roleB));
        if (p != 0) return p;

        final nameA = widget.membersById[a]?.name ?? '';
        final nameB = widget.membersById[b]?.name ?? '';
        return nameA.toLowerCase().compareTo(nameB.toLowerCase());
      });

    final total = userIds.length;
    final visible = _visible.clamp(0, total);

    if (total == 0) return Text(loc.noUserRolesAvailable);

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visible,
          itemBuilder: (_, i) {
            final userId = userIds[i];
            final role = widget.userRoles[userId] ?? 'member';
            final user = widget.membersById[userId];
            final editable = widget.canEditRole(userId);

            return _memberTile(
              context: context,
              userId: userId,
              role: role,
              user: user,
              editable: editable,
              roles: widget.assignableRoles,
              onRoleChanged: (newRole) => widget.setRole(userId, newRole),
              onRemove:
                  editable ? () => widget.onRemoveUser?.call(userId) : null,
            );
          },
        ),
        if (visible < total)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.expand_more),
              label: Text('Load more (${total - visible})'),
              onPressed: () => setState(() => _visible += _pageSize),
            ),
          ),
      ],
    );
  }

  Widget _memberTile({
    required BuildContext context,
    required String userId,
    required String role,
    required User? user,
    required bool editable,
    required List<String> roles,
    required ValueChanged<String> onRoleChanged,
    required VoidCallback? onRemove,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final name = user?.name.isNotEmpty == true
        ? user!.name
        : user?.userName ?? 'Unknown';

    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          leading: CircleAvatar(
            radius: 20,
            backgroundImage: (user?.photoUrl?.isNotEmpty ?? false)
                ? NetworkImage(user!.photoUrl!)
                : null,
            child: (user?.photoUrl?.isEmpty ?? true)
                ? Text(name[0].toUpperCase())
                : null,
          ),
          title: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(
            user?.email ?? user?.userName ?? userId,
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
                      options: {...roles, role}.toList(),
                      onChanged: onRoleChanged,
                    )
                  : Container(
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
            ),
          ),
          onLongPress: onRemove,
        ),
        const Divider(height: 1),
      ],
    );
  }
}

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

String _localizedRole(BuildContext context, String role) {
  final loc = AppLocalizations.of(context)!;
  switch (role.toLowerCase()) {
    case 'owner':
      return loc.administrator; // reuse admin label
    case 'admin':
      return loc.administrator;
    case 'co-admin':
      return loc.coAdministrator;
    default:
      return loc.member;
  }
}
