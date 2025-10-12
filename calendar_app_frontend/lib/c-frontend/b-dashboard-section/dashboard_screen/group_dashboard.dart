import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
// REMOVED: userInvitation_status import
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/Members_count.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/upcoming_events/group_upcoming_events.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/e-drawer-style-menu/contextual_fab.dart';
import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:hexora/f-themes/utilities/utilities.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupDashboard extends StatefulWidget {
  final Group group;
  const GroupDashboard({super.key, required this.group});

  @override
  State<GroupDashboard> createState() => _GroupDashboardState();
}

class _GroupDashboardState extends State<GroupDashboard> {
  late GroupDomain _gm;
  MembersCount? _counts;
  bool _loadingCounts = false;

  @override
  void initState() {
    super.initState();
    _gm = context.read<GroupDomain>(); // ✅ use management → repository
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
      // fallback UI will still show local numbers
    } finally {
      if (mounted) setState(() => _loadingCounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l = AppLocalizations.of(context)!;

    final createdStr = DateFormat.yMMMd(l.localeName).format(group.createdTime);

    // ---- SIMPLE LOCAL FALLBACK COUNTS ----
    // Since invites are now a separate collection, we can’t infer pending locally.
    // We show members from local group doc and rely on server counts when available.
    final fallbackMembers = group.userIds.length;
    const fallbackPending = 0; // unknown locally without querying invitations
    final fallbackTotal = fallbackMembers + fallbackPending;

    // ---- SERVER-FIRST DISPLAY ----
    final showMembers = _counts?.accepted ?? fallbackMembers;
    final showPending = _counts?.pending ?? fallbackPending;
    final showTotal = _counts?.union ?? fallbackTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.dashboardTitle),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ---- Overview ----
            _SectionHeader(title: l.sectionOverview),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: Utilities.buildProfileImage(group.photoUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: tt.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.createdOnDay(createdStr),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Members / Pending / Total pills (server-first)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoPill(
                            icon: Icons.group_outlined,
                            label:
                                '${NumberFormat.decimalPattern(l.localeName).format(showMembers)} ${l.membersTitle.toLowerCase()}',
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.groupMembers,
                                arguments: group,
                              );
                            },
                          ),
                          _InfoPill(
                            icon: Icons.hourglass_top_outlined,
                            label:
                                '${NumberFormat.decimalPattern(l.localeName).format(showPending)} ${l.statusPending.toLowerCase()}',
                          ),
                          _InfoPill(
                            icon: Icons.all_inbox_outlined,
                            label:
                                '${NumberFormat.decimalPattern(l.localeName).format(showTotal)} total',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---- Upcoming ----
            _SectionHeader(title: l.sectionUpcoming),
            GroupUpcomingEventsCard(groupId: group.id),

            const SizedBox(height: 20),

            // ---- Manage ----
            _SectionHeader(title: l.sectionManage),
            Card(
              color: ThemeColors.getListTileBackgroundColor(context),
              child: ListTile(
                leading: const Icon(Icons.group_outlined),
                title: Text(l.membersTitle),
                subtitle: Text(
                    '${NumberFormat.decimalPattern(l.localeName).format(showMembers)} ${l.membersTitle.toLowerCase()}'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.groupMembers,
                    arguments: group,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: ThemeColors.getListTileBackgroundColor(context),
              child: ListTile(
                leading: const Icon(Icons.design_services_outlined),
                title: Text(l.servicesClientsTitle),
                subtitle: Text(l.servicesClientsSubtitle),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.groupServicesClients,
                    arguments: group,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // ---- Insights / Graphs ----
            _SectionHeader(title: l.sectionInsights),
            Card(
              color: ThemeColors.getListTileBackgroundColor(context),
              child: ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: Text(l.insightsTitle),
                subtitle: Text(l.insightsSubtitle),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.groupInsights,
                    arguments: group,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ---- Status (only if missing calendar) ----
            if (!group.hasCalendar) ...[
              _SectionHeader(title: l.sectionStatus),
              Card(
                color: cs.errorContainer.withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l.noCalendarWarning,
                    style: tt.bodyMedium?.copyWith(color: cs.error),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 96),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 56,
          child: FilledButton.icon(
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(l.goToCalendar),
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.groupCalendar,
                arguments: group,
              );
            },
          ),
        ),
      ),
      floatingActionButton: const ContextualFab(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(title,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              color: cs.onSurface.withOpacity(0.08),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small clickable pill used to surface quick stats (e.g., members total).
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _InfoPill({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = cs.surfaceVariant.withOpacity(0.6);
    final fg = cs.onSurface.withOpacity(0.8);

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                fontSize: 12.5, color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: pill,
    );
  }
}
