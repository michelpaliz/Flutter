import 'package:calendar_app_frontend/a-models/notification_model/notification_user.dart';
import 'package:calendar_app_frontend/c-frontend/routes/appRoutes.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';

// This widget plugs into the AppBar and manages:
//     Live unread notification badge
//     Navigation to the notifications screen
//     Marking notifications as read

Widget buildNotificationIcon({
  required BuildContext context,
  required UserManagement userManagement,
  required NotificationManagement notificationManagement,
}) {
  final currentUser = userManagement.user;

  if (currentUser == null) {
    return IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        // Optional: show login warning or redirect
      },
    );
  }

  return StreamBuilder<List<NotificationUser>>(
    stream: notificationManagement.notificationStream,
    builder: (context, snapshot) {
      final notifications = snapshot.data ?? [];
      final unread = notifications.where((n) => !n.isRead).toList();
      final hasUnread = unread.isNotEmpty;

      return IconButton(
        icon: Stack(
          alignment: Alignment.topRight,
          children: [
            const Icon(Icons.notifications),
            if (hasUnread)
              const Positioned(
                right: 0,
                child: Icon(Icons.brightness_1, size: 10, color: Colors.red),
              ),
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.showNotifications,
            arguments: currentUser,
          );
          notificationManagement.markAllNotificationsAsRead(userManagement);
        },
      );
    },
  );
}
