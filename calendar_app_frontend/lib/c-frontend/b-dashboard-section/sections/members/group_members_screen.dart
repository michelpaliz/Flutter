import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/members_ref.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/empty_hint.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/members_row_widgets/parent/members_row.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/utils/selected_users/filter_chips.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'utils/member_status.dart';
import 'widgets/section_header.dart';

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
    final l = AppLocalizations.of(context)!;

    final invited =
        widget.group.invitedUsers ?? const <String, UserInviteStatus>{};
    final roles = widget.group.userRoles; // username -> role
    final acceptedSet = widget.group.userIds.toSet(); // usernames

    final usernames = <String>{}
      ..addAll(acceptedSet)
      ..addAll(invited.keys);

    final members = usernames.map((u) {
      final inv = invited[u];
      final statusToken =
          statusFor(u, inv, acceptedSet); // Accepted | Pending | NotAccepted
      final role = roles[u] ?? inv?.role ?? 'member';
      return MemberRef(username: u, role: role, statusToken: statusToken);
    }).toList()
      ..sort((a, b) =>
          a.username.toLowerCase().compareTo(b.username.toLowerCase()));

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

    final accepted =
        filtered.where((m) => m.statusToken == 'Accepted').toList();
    final pending = filtered.where((m) => m.statusToken == 'Pending').toList();
    final notAccepted =
        filtered.where((m) => m.statusToken == 'NotAccepted').toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.membersTitle)),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SectionHeader(title: l.sectionFilters),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilterChips(
              showAccepted: showAccepted,
              showPending: showPending,
              showNotWantedToJoin: showNotAccepted,
              acceptedText: l.statusAccepted,
              pendingText: l.statusPending,
              notAcceptedText: l.statusNotAccepted,
              onFilterChange: (token, selected) {
                setState(() {
                  if (token == 'Accepted') showAccepted = selected;
                  if (token == 'Pending') showPending = selected;
                  if (token == 'NotAccepted') showNotAccepted = selected;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: (accepted.isEmpty && pending.isEmpty && notAccepted.isEmpty)
                ? EmptyHint(
                    title: l.noMembersTitle,
                    message: l.noMembersMatchFilters,
                    tip: l.tryAdjustingFilters,
                  )
                : ListView(
                    children: [
                      if (accepted.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: SectionHeader(title: l.statusAccepted),
                        ),
                        ..._buildSectionList(context, accepted),
                      ],
                      if (pending.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: SectionHeader(title: l.statusPending),
                        ),
                        ..._buildSectionList(context, pending),
                      ],
                      if (notAccepted.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: SectionHeader(title: l.statusNotAccepted),
                        ),
                        ..._buildSectionList(context, notAccepted),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSectionList(BuildContext context, List<MemberRef> refs) {
    return List.generate(refs.length * 2 - 1, (i) {
      if (i.isOdd) return const Divider(height: 1);
      final ref = refs[i ~/ 2];
      return MemberRow(
          ref: ref, ownerId: widget.group.ownerId); // 👈 pass ownerId
    });
  }
}
