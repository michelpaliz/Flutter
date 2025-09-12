import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/c-frontend/b-group-section/sections/upcoming_events/group_upcoming_events.dart';
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

    return Scaffold(
      appBar: AppBar(
        // 👇 Use a single, stable screen title
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Single place where the group name appears ---
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
                    // 👇 Only here
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
              // Optional: a small “chip” hinting the section
              // const Chip(label: Text('Dashboard')),
            ],
          ),
          const SizedBox(height: 16),

          // --- NEW: Next upcoming events for THIS group only ---
          GroupUpcomingEventsCard(groupId: group.id),

          const SizedBox(height: 16),

          // Quick tiles
          Card(
            child: ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text('Members'),
              subtitle: Text('${group.userIds.length} total'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.groupMembers, // 👈 goes to the new screen
                  arguments: group,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.design_services_outlined),
              title: const Text('Services & Clients'),
              subtitle: const Text('Create and manage services/clients'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.groupServicesClients,
                  arguments: group,
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          if (!group.hasCalendar)
            Card(
              color: colorScheme.errorContainer.withOpacity(0.15),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'This group has no calendar linked yet.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 96), // breathing room above bottom button
        ],
      ),

      // Big, reachable primary action at the bottom
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 56,
          child: FilledButton.icon(
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(AppLocalizations.of(context)!.goToCalendar),
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

      // Optional: keep or remove this if you want only one entry point
      floatingActionButton: const ContextualFab(),
    );
  }
}
