import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/api/notification/notification_services.dart';
import 'package:first_project/b-backend/api/user/user_services.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/notification/notification_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';

class NotificationController {
  final UserManagement userManagement;
  final GroupManagement groupManagement;
  final NotificationManagement notificationManagement;
  final UserService userService;
  final NotificationService notificationService; // 👈 New dependency

  NotificationController({
    required this.userManagement,
    required this.groupManagement,
    required this.notificationManagement,
    required this.userService,
    required this.notificationService, // 👈 Inject the service
  });

  /// ✅ Fetch notifications for a user and update stream
  Future<void> fetchAndUpdateNotifications(User user) async {
    try {
      final fetched =
          await notificationService.getNotificationsForUser(user.userName);
      fetched.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notificationManagement.updateNotificationStream(fetched);
    } catch (e) {
      devtools.log('❌ Error fetching notifications: $e');
    }
  }

  /// ✅ Handle "Accept" response to a group invite
  Future<void> handleConfirmation(NotificationUser notification) async {
    try {
      final group =
          await groupManagement.groupService.getGroupById(notification.groupId);
      final user = await userService.getUserById(notification.recipientId);

      // Notify backend (accept)
      await groupManagement.groupService.respondToInvite(
        groupId: group.id,
        username: user.userName,
        accepted: true,
      );

      // Refresh state
      final freshUser = await userManagement.getUser();
      if (freshUser != null) {
        userManagement.setCurrentUser(freshUser);
        await groupManagement.fetchAndInitializeGroups(freshUser.groupIds);
      }

      // Remove notification from backend
      await notificationService
          .deleteNotification(notification.id); // 👈 Backend cleanup
      await notificationManagement.removeNotificationById(
        notification.id,
        userManagement,
      );
    } catch (e) {
      devtools.log('❌ Error confirming invitation: $e');
    }
  }

  /// ✅ Handle "Decline" response to a group invite
  Future<void> handleNegation(NotificationUser notification) async {
    try {
      final group =
          await groupManagement.groupService.getGroupById(notification.groupId);
      final user = await userService.getUserById(notification.recipientId);

      // Notify backend (decline)
      await groupManagement.groupService.respondToInvite(
        groupId: group.id,
        username: user.userName,
        accepted: false,
      );

      // Refresh state
      final freshUser = await userManagement.getUser();
      if (freshUser != null) {
        userManagement.setCurrentUser(freshUser);
        await groupManagement.fetchAndInitializeGroups(freshUser.groupIds);
      }

      // Remove notification from backend
      await notificationService
          .deleteNotification(notification.id); // 👈 Backend cleanup
      await notificationManagement.removeNotificationById(
        notification.id,
        userManagement,
      );
    } catch (e) {
      devtools.log('❌ Error declining invitation: $e');
    }
  }

  /// ✅ Remove a notification by its index in the local list
  Future<void> removeNotificationByIndex(int index) async {
    final notification = notificationManagement.notifications[index];

    // Remove from backend
    await notificationService
        .deleteNotification(notification.id); // 👈 Optional
    await notificationManagement.removeNotificationByIndex(
        index, userManagement);
  }

  /// ✅ Remove all notifications from the current user (local + DB)
  Future<void> removeAllNotifications(User user) async {
    // ⚠️ Optional: loop through and delete each notification from backend
    for (final notif in notificationManagement.notifications) {
      await notificationService.deleteNotification(notif.id);
    }

    notificationManagement.clearNotifications(); // Local cleanup
    user.notifications.clear(); // Clean user object
    await userManagement.userService.updateUser(user); // Update DB
  }
}
