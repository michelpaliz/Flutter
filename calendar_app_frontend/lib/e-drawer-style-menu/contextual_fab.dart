import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/b-backend/api/notification/notification_services.dart';
import 'package:calendar_app_frontend/b-backend/api/user/user_services.dart';
import 'package:calendar_app_frontend/c-frontend/e-notification-section/controllers/notification_controller.dart';
import 'package:calendar_app_frontend/c-frontend/routes/appRoutes.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/f-themes/palette/app_colors.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class ContextualFab extends StatelessWidget {
  const ContextualFab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppDarkColors.primary : AppColors.primary;

    // Current route & args
    final settings = ModalRoute.of(context)?.settings;
    final name = settings?.name ?? '';
    final args = settings?.arguments;
    final groupArg = args is Group ? args : null;

    // Pick icon + action by context (Iconsax)
    IconData iconData = Iconsax.add;
    VoidCallback? onPressed;

    // 1) If we already have a Group (e.g., from group calendar) → Add Event
    if (groupArg != null) {
      iconData = Iconsax.calendar_add;
      onPressed = () =>
          Navigator.pushNamed(context, AppRoutes.addEvent, arguments: groupArg);
    }
    // 2) On Show Groups → Create Group
    else if (name == AppRoutes.homePage || name.isEmpty) {
      iconData = Iconsax.add_circle;
      onPressed = () => Navigator.pushNamed(context, AppRoutes.createGroupData);
    }
    // 3) On Agenda → pick a group then Add Event
    else if (name == AppRoutes.agenda) {
      iconData = Iconsax.calendar_add;
      onPressed = () => _pickGroupAndAddEvent(context);
    }
    // 4) On Notifications → Clear all
    else if (name == AppRoutes.showNotifications) {
      iconData = Iconsax.trash; // clear all
      onPressed = () => _confirmAndClearAllNotifications(context);
    }
    // 5) Hide on Profile
    else if (name == AppRoutes.profile) {
      onPressed = null;
    }
    // 6) Fallback → go to Create Group
    else {
      iconData = Iconsax.add_circle;
      onPressed = () => Navigator.pushNamed(context, AppRoutes.createGroupData);
    }

    if (onPressed == null) return const SizedBox.shrink();

    // ---- Circular FAB with gradient ring + top-only glow ----
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            baseColor.withOpacity(0.65),
            baseColor,
          ],
        ),
        boxShadow: [
          // top-only glow: negative Y offset
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3), // ring thickness
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton(
          onPressed: onPressed,
          elevation: 0, // no default downward shadow
          shape: const CircleBorder(), // circular
          backgroundColor: baseColor,
          foregroundColor: Colors.white,
          child: Icon(iconData, size: 26),
        ),
      ),
    );
  }

  Future<void> _confirmAndClearAllNotifications(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final user = context.read<UserManagement>().user;

    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.zeroNotifications)),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(loc.clearAllConfirmTitle), // e.g. "Clear all?"
            content: Text(
                loc.clearAllConfirmMessage), // e.g. "Remove all notifications?"
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(loc.clearAll),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final controller = NotificationController(
      userManagement: context.read<UserManagement>(),
      groupManagement: context.read<GroupManagement>(),
      notificationManagement: context.read<NotificationManagement>(),
      userService: UserService(),
      notificationService: NotificationService(),
    );

    await controller.removeAllNotifications(user);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.clearedAllSuccess)),
      );
    }
  }

  Future<void> _pickGroupAndAddEvent(BuildContext context) async {
    final gm = context.read<GroupManagement>();
    final groups = gm.groups;

    if (groups.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No groups available')));
      }
      return;
    }

    final selected = await showModalBottomSheet<Group>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final g = groups[i];
            return ListTile(
              title: Text(g.name),
              leading: const Icon(Iconsax.profile_2user),
              onTap: () => Navigator.pop(ctx, g),
            );
          },
        ),
      ),
    );

    if (selected != null && context.mounted) {
      Navigator.pushNamed(context, AppRoutes.addEvent, arguments: selected);
    }
  }
}
