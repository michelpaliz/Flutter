import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileDetailsCard extends StatelessWidget {
  final String email, username, userId;
  final int groupsCount, calendarsCount, notificationsCount;
  final VoidCallback onCopyEmail,
      onCopyId,
      onTapUsername,
      onTapTeams,
      onTapCalendars,
      onTapNotifications;

  const ProfileDetailsCard({
    super.key,
    required this.email,
    required this.username,
    required this.userId,
    required this.groupsCount,
    required this.calendarsCount,
    required this.notificationsCount,
    required this.onCopyEmail,
    required this.onCopyId,
    required this.onTapUsername,
    required this.onTapTeams,
    required this.onTapCalendars,
    required this.onTapNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bg = ThemeColors.getCardBackgroundColor(context).withOpacity(0.98);
    final onSurfaceVar = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget tile({
      required IconData icon,
      required String title,
      String? subtitle,
      Widget? trailing,
      VoidCallback? onTap,
    }) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              color: onSurfaceVar.withOpacity(.12), shape: BoxShape.circle),
          child: Icon(icon),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: subtitle == null
            ? null
            : Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: onSurfaceVar)),
        trailing: trailing,
        onTap: onTap,
      );
    }

    return Container(
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          tile(
            icon: Icons.alternate_email_rounded,
            title: l10n.email,
            subtitle: email,
            trailing: const Icon(Icons.copy_rounded),
            onTap: onCopyEmail,
          ),
          const Divider(height: 0),
          tile(
            icon: Icons.badge_rounded,
            title: l10n.username,
            subtitle: username,
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onTapUsername,
          ),
          const Divider(height: 0),
          tile(
            icon: Icons.fingerprint_rounded,
            title: l10n.userId,
            subtitle: userId,
            trailing: const Icon(Icons.copy_rounded),
            onTap: onCopyId,
          ),
          const Divider(height: 0),
          tile(
            icon: Icons.groups_3_rounded,
            title: l10n.teams,
            subtitle: l10n.teamCount(groupsCount),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onTapTeams,
          ),
          const Divider(height: 0),
          tile(
            icon: Icons.calendar_month_rounded,
            title: l10n.calendars,
            subtitle: l10n.calendarCount(calendarsCount),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onTapCalendars,
          ),
          const Divider(height: 0),
          tile(
            icon: Icons.notifications_active_rounded,
            title: l10n.notifications,
            // keeping subtitle as plain number per current UI
            subtitle: '$notificationsCount',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onTapNotifications,
          ),
        ],
      ),
    );
  }
}
