import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/Members_count.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/upcoming_events/group_upcoming_events.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/e-drawer-style-menu/contextual_fab.dart';
import 'package:hexora/f-themes/app_colors/themes/text_styles/typography_extension.dart';
import 'package:hexora/f-themes/app_colors/tools_colors/theme_colors.dart';
import 'package:hexora/f-themes/app_utilities/image/avatar_utils.dart';
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
    _gm = context.read<GroupDomain>();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() => _loadingCounts = true);
    try {
      final c = await _gm.groupRepository.getMembersCount(
        widget.group.id,
        mode: 'union',
      );
      if (!mounted) return;
      setState(() => _counts = c);
    } finally {
      if (mounted) setState(() => _loadingCounts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final cs = Theme.of(context).colorScheme;
    final t = AppTypography.of(context);
    final l = AppLocalizations.of(context)!;

    // typography hierarchy (one place to tweak if needed)
    final sectionTitleStyle = t.bodyLarge.copyWith(fontWeight: FontWeight.w800);
    final tileTitleStyle = t.accentText.copyWith(fontWeight: FontWeight.w600);
    final tileSubtitleStyle = t.bodySmall;

    final createdStr = DateFormat.yMMMd(l.localeName).format(group.createdTime);

    // Fallbacks
    final fallbackMembers = group.userIds.length;
    const fallbackPending = 0;
    final fallbackTotal = fallbackMembers + fallbackPending;

    // Server-first
    final showMembers = _counts?.accepted ?? fallbackMembers;
    final showPending = _counts?.pending ?? fallbackPending;
    final showTotal = _counts?.union ?? fallbackTotal;

    return Scaffold(
      appBar: AppBar(
        // Keep app bar prominent
        title: Text(l.dashboardTitle, style: t.titleLarge),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCounts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(title: l.sectionOverview, style: sectionTitleStyle),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AvatarUtils.groupAvatar(context, group.photoUrl, radius: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name,
                          style: t.titleLarge
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        l.createdOnDay(createdStr),
                        style: t.bodySmall.copyWith(
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
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
            _SectionHeader(title: l.sectionUpcoming, style: sectionTitleStyle),
            GroupUpcomingEventsCard(groupId: group.id),
            const SizedBox(height: 20),
            _SectionHeader(title: l.sectionManage, style: sectionTitleStyle),
            Card(
              color: ThemeColors.getListTileBackgroundColor(context),
              child: ListTile(
                leading: const Icon(Icons.group_outlined),
                // ↓ inner tile titles are now smaller
                title: Text(l.membersTitle, style: tileTitleStyle),
                subtitle: Text(
                  '${NumberFormat.decimalPattern(l.localeName).format(showMembers)} ${l.membersTitle.toLowerCase()}',
                  style: tileSubtitleStyle,
                ),
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
                title: Text(l.servicesClientsTitle, style: tileTitleStyle),
                subtitle:
                    Text(l.servicesClientsSubtitle, style: tileSubtitleStyle),
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
            _SectionHeader(title: l.sectionInsights, style: sectionTitleStyle),
            Card(
              color: ThemeColors.getListTileBackgroundColor(context),
              child: ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: Text(l.insightsTitle, style: tileTitleStyle),
                subtitle: Text(l.insightsSubtitle, style: tileSubtitleStyle),
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
            if (!group.hasCalendar) ...[
              _SectionHeader(title: l.sectionStatus, style: sectionTitleStyle),
              Card(
                color: cs.errorContainer.withOpacity(0.15),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l.noCalendarWarning,
                    style: t.bodyMedium.copyWith(color: cs.error),
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
            label: Text(l.goToCalendar, style: t.buttonText),
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
  final TextStyle? style;
  const _SectionHeader({required this.title, this.style});

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            // keep sections clearly above inner tiles
            style:
                (style ?? t.titleLarge).copyWith(fontWeight: FontWeight.w800),
          ),
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
    final t = AppTypography.of(context);

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
            style: t.bodySmall.copyWith(color: fg, fontWeight: FontWeight.w600),
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
