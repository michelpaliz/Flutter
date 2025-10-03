// widgets/members_list.dart
import 'package:flutter/material.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/members_ref.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/empty_hint.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/member_list/members_row_widgets/parent/members_row.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/section_header.dart';
import 'package:hexora/l10n/app_localizations.dart';

class MembersList extends StatelessWidget {
  final List<MemberRef> accepted;
  final List<MemberRef> pending;
  final List<MemberRef> notAccepted;

  final String acceptedLabel; // "Members"
  final String pendingLabel; // localized
  final String notAcceptedLabel; // localized

  const MembersList({
    super.key,
    required this.accepted,
    required this.pending,
    required this.notAccepted,
    required this.acceptedLabel,
    required this.pendingLabel,
    required this.notAcceptedLabel,
  });

  bool _isAdminRole(String role) {
    final s = role.trim().toLowerCase();
    return s == 'admin' ||
        s == 'administrator' ||
        s == 'manager' ||
        s == 'moderator';
  }

  bool _isMemberRole(String role) {
    final s = role.trim().toLowerCase();
    return s == 'member' || s.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    final nothing = accepted.isEmpty && pending.isEmpty && notAccepted.isEmpty;

    if (nothing) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: EmptyHint(
          title: l.noMembersTitle,
          message: l.noMembersMatchFilters,
          tip: l.tryAdjustingFilters,
        ),
      );
    }

    // Split accepted members into admins and regular members
    final adminMembers =
        accepted.where((ref) => _isAdminRole(ref.role)).toList();
    final regularMembers =
        accepted.where((ref) => _isMemberRole(ref.role)).toList();
    final otherRoleMembers = accepted
        .where((ref) => !_isAdminRole(ref.role) && !_isMemberRole(ref.role))
        .toList();

    List<Widget> buildSection(String title, List<MemberRef> refs,
        {Color? color, String? sectionType}) {
      if (refs.isEmpty) return const [];
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: SectionHeader(
            title: title,
            textStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color ?? colors.onSurface,
            ),
          ),
        ),
        ...refs.map(
          (ref) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colors.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 68,
                ),
                child: MemberRow(
                  ref: ref,
                  ownerId: ref.ownerId,
                  showRoleChip: sectionType !=
                      'admins', // Don't show role chip for admins section since they're already identified as admins
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        // Admins section first
        ...buildSection(l.roleAdmin, adminMembers,
            color: colors.secondary, sectionType: 'admins'),

        // Regular members section
        ...buildSection(acceptedLabel, regularMembers,
            color: colors.primary, sectionType: 'members'),

//TODO ADD CO-ADMIN ROLE HERE
        // Other roles section (if any)
        // if (otherRoleMembers.isNotEmpty)
        //   ...buildSection(l.otherRoles, otherRoleMembers,
        //       color: colors.tertiary, sectionType: 'other'),

        // Pending section
        ...buildSection(pendingLabel, pending, color: colors.onSurfaceVariant),

        // Not accepted section
        ...buildSection(notAcceptedLabel, notAccepted,
            color: colors.onSurfaceVariant),

        const SizedBox(height: 24),
      ],
    );
  }
}
