import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/c-frontend/routes/appRoutes.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/contextual_fab.dart';
import 'package:calendar_app_frontend/f-themes/utilities/utilities.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';


class GroupDashboard extends StatelessWidget {
  final Group group;
  const GroupDashboard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      '${group.createdTime.year}-${group.createdTime.month.toString().padLeft(2, '0')}-${group.createdTime.day.toString().padLeft(2, '0')}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick actions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // “Go to calendar” button inside the dashboard
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(loc.goToCalendar),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.groupCalendar,
                          arguments: group,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!group.hasCalendar)
                    Text(
                      'This group has no calendar linked yet.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Example sections you can expand later
          Card(
            child: ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('Members'),
              subtitle: Text('${group.userIds.length} total'),
              onTap: () {
                // TODO: navigate to your members list page (if any)
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Group settings'),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.groupSettings,
                    arguments: group);
              },
            ),
          ),
        ],
      ),

      // Use your shared FAB; ContextualFab now routes to calendar on this page.
      floatingActionButton: const ContextualFab(),
    );
  }
}