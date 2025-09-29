import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/upcoming_events/group_upcoming_events.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/e-drawer-style-menu/contextual_fab.dart';
import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:hexora/f-themes/utilities/utilities.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupDashboard extends StatelessWidget {
  final Group group;
  const GroupDashboard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final l = AppLocalizations.of(context)!;

    final createdStr = DateFormat.yMMMd(l.localeName).format(group.createdTime);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.dashboardTitle),
      ),
      body: ListView(
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
                    Text(group.name,
                        style: tt.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      l.createdOnDay(createdStr),
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.7),
                      ),
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
              subtitle: Text(l.membersSubtitle(group.userIds.length)),
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
