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

  // --- Role helpers ----------------------------------------------------------

  String _norm(String role) =>
      role.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  bool _isCoAdminRole(String role) {
    final s = _norm(role);
    // handles: "co-admin", "coadmin", "co administrator", "co administrator (something)"
    return s.contains('co-admin') ||
        s.contains('coadmin') ||
        s.contains('co administrator');
  }

  bool _isAdminRole(String role) {
    final s = _norm(role);
    // treat "owner" and "administrator" as admin; exclude co-admins here so they get their own bucket
    if (_isCoAdminRole(role)) return false;
    return s == 'admin' ||
        s.contains('administrator') ||
        s.contains('owner') || // e.g. "administrator (owner)"
        s == 'manager' ||
        s == 'moderator';
  }

  bool _isMemberRole(String role) {
    final s = _norm(role);
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

    // --- Split accepted users: Admin -> Co-Admin -> Member -------------------
    final adminMembers = accepted.where((r) => _isAdminRole(r.role)).toList();
    final coAdminMembers =
        accepted.where((r) => _isCoAdminRole(r.role)).toList();
    final regularMembers =
        accepted.where((r) => _isMemberRole(r.role)).toList();
    // (optional) anything else (custom roles) could be bucketed here if needed:
    // final otherRoleMembers = accepted.where((r) =>
    //   !_isAdminRole(r.role) && !_isCoAdminRole(r.role) && !_isMemberRole(r.role)
    // ).toList();

    List<Widget> buildSection(
      String title,
      List<MemberRef> refs, {
      Color? color,
      String? sectionType,
    }) {
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
                constraints: const BoxConstraints(minHeight: 68),
                child: MemberRow(
                  ref: ref,
                  ownerId: ref.ownerId,
                  // SHOW the role chip for *all* sections so Admins/Co-Admins are labeled
                  showRoleChip: true,
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
        // 1) Admins
        ...buildSection(
          l.roleAdmin, // make sure you have this key localized (e.g., "Administrador")
          adminMembers,
          color: colors.secondary,
          sectionType: 'admins',
        ),

        // 2) Co-Admins
        ...buildSection(
          l.roleCoAdmin, // add localization key (e.g., "Co-administrador")
          coAdminMembers,
          color: colors.tertiary,
          sectionType: 'coadmins',
        ),

        // 3) Members
        ...buildSection(
          acceptedLabel, // typically something like l.members
          regularMembers,
          color: colors.primary,
          sectionType: 'members',
        ),

        // (Optional) Other roles if you decide to surface them:
        // if (otherRoleMembers.isNotEmpty)
        //   ...buildSection(l.otherRoles, otherRoleMembers,
        //       color: colors.onTertiaryContainer, sectionType: 'other'),

        // Pending / Not accepted (kept unsplit by role on purpose)
        ...buildSection(pendingLabel, pending, color: colors.onSurfaceVariant),
        ...buildSection(notAcceptedLabel, notAccepted,
            color: colors.onSurfaceVariant),

        const SizedBox(height: 24),
      ],
    );
  }
}
