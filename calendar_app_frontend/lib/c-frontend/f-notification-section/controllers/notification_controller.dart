import 'dart:developer' as devtools show log;

import 'package:hexora/a-models/notification_model/notification_user.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/api/notification/notification_services.dart';
import 'package:hexora/b-backend/api/user/user_services.dart';
import 'package:hexora/d-stateManagement/group/group_management.dart';
import 'package:hexora/d-stateManagement/notification/notification_management.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';

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
      final fetched = await notificationService.getNotificationsForUser(
        user.userName,
      );
      fetched.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notificationManagement.updateNotificationStream(fetched);
    } catch (e) {
      devtools.log('❌ Error fetching notifications: $e');
    }
  }

  /// ✅ Handle "Accept" response to a group invite
  Future<void> handleConfirmation(NotificationUser notification) async {
    try {
      final group = await groupManagement.groupService.getGroupById(
        notification.groupId,
      );
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
      await notificationService.deleteNotification(
        notification.id,
      ); // 👈 Backend cleanup
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
      final group = await groupManagement.groupService.getGroupById(
        notification.groupId,
      );
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
      await notificationService.deleteNotification(
        notification.id,
      ); // 👈 Backend cleanup
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
    await notificationService.deleteNotification(
      notification.id,
    ); // 👈 Optional
    await notificationManagement.removeNotificationByIndex(
      index,
      userManagement,
    );
  }

  /// Remove all notifications for the current user (DB + local)
  Future<void> removeAllNotifications(User user) async {
    try {
      await notificationService.deleteAllMine(); // <-- one backend call
      notificationManagement.clearNotifications(); // local state
      // No need to mutate user.notifications or push a user update here.
      // If you want, you can refresh from backend:
      await fetchAndUpdateNotifications(user);
    } catch (e) {
      devtools.log('❌ Error removing all notifications: $e');
      rethrow;
    }
  }
}
