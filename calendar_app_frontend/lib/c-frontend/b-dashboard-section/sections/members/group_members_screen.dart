// group_members_screen.dart
import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/Members_count.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/members_ref.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/utils/member_derivation.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/utils/member_status.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/count_pills.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/member_list/member_list.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/utils/selected_users/filter_chips.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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

  MembersCount? _counts;
  bool _loadingCounts = false;

  late GroupDomain _gm;

  @override
  void initState() {
    super.initState();
    _gm = context.read<GroupDomain>(); // ✅ use Management → Repository
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _loadingCounts = true);
    try {
      final c = await _gm.groupRepository.getMembersCount(
        widget.group.id,
        mode: 'union', // or 'accepted'
      );
      if (!mounted) return;
      setState(() => _counts = c);
    } catch (_) {
      // ignore; local derivation still renders
    } finally {
      if (mounted) setState(() => _loadingCounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // --- derive local sets (accepted/pending) ---
    final deriv = deriveAcceptedAndPending(
      userIds: widget.group.userIds,
      invitedUsers: widget.group.invitedUsers,
    );

    // union for list building
    final allKeys = <String>{}
      ..addAll(deriv.accepted)
      ..addAll(deriv.pending.keys);

    // map to MemberRef (ownerId is needed by MemberRow—pass it as needed)
    final members = allKeys.map((k) {
      final inv = deriv.pending[k]; // null if accepted
      final statusToken = statusFor(k, inv, deriv.accepted);
      final role = (widget.group.userRoles)[k] ?? inv?.role ?? 'member';
      return MemberRef(
        username: k,
        role: role,
        statusToken: statusToken,
        ownerId: widget.group.ownerId,
      );
    }).toList()
      ..sort((a, b) =>
          a.username.toLowerCase().compareTo(b.username.toLowerCase()));

    // filters
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

    final membersLabel = l.membersTitle;
    final pendingLabel = l.statusPending;
    final notAcceptedLabel = l.statusNotAccepted;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.membersTitle,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colors.surface,
        elevation: 0.5,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      body: RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.surface,
        onRefresh: _loadCounts,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // COUNTS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CountsPills(
                loading: _loadingCounts,
                members: _counts?.accepted,
                pending: _counts?.pending,
                total: _counts?.union,
                fallbackMembers: deriv.accepted.length,
                fallbackPending: deriv.pending.length,
                membersLabel: membersLabel,
                pendingLabel: pendingLabel,
                totalLabel: 'Total', // localize if desired
              ),
            ),

            const SizedBox(height: 24),

            // FILTERS
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: l.sectionFilters,
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilterChips(
                    showAccepted: showAccepted,
                    showPending: showPending,
                    showNotWantedToJoin: showNotAccepted,
                    acceptedText: membersLabel, // “Accepted” → “Members”
                    pendingText: pendingLabel,
                    notAcceptedText: notAcceptedLabel,
                    onFilterChange: (token, selected) {
                      setState(() {
                        if (token == 'Accepted') showAccepted = selected;
                        if (token == 'Pending') showPending = selected;
                        if (token == 'NotAccepted') showNotAccepted = selected;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LIST
            Expanded(
              child: MembersList(
                accepted: accepted,
                pending: pending,
                notAccepted: notAccepted,
                acceptedLabel: membersLabel,
                pendingLabel: pendingLabel,
                notAcceptedLabel: notAcceptedLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
