import 'dart:developer' as devtools show log;

import 'package:hexora/a-models/notification_model/notification_user.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/notification/domain/notification_domain.dart';
// ⛔ remove: import 'package:hexora/b-backend/api/user/user_services.dart';
import 'package:hexora/b-backend/notification/notification_api_client.dart';

class NotificationController {
  final UserDomain userDomain;
  final GroupDomain groupDomain;
  final NotificationDomain notificationDomain;

  // If your notification layer was also split, prefer NotificationRepository.
  final NotificationApiClient notificationService;

  NotificationController({
    required this.userDomain,
    required this.groupDomain,
    required this.notificationDomain,
    required this.notificationService,
  });

  /// ✅ Fetch notifications for a user and update stream
  Future<void> fetchAndUpdateNotifications(User user) async {
    try {
      final fetched = await notificationService.getNotificationsForUser(
        user.userName,
      );
      fetched.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notificationDomain.updateNotificationStream(fetched);
    } catch (e) {
      devtools.log('❌ Error fetching notifications: $e');
    }
  }

  /// ✅ Handle "Accept" response to a group invite
  Future<void> handleConfirmation(NotificationUser notification) async {
    try {
      // 🔄 Fetch via repository (token handled inside)
      final group =
          await groupDomain.groupRepository.getGroupById(notification.groupId);

      // Prefer a UM helper; otherwise use UM.userRepository.getUserById(...)
      final user = await userDomain.getUserById(notification.recipientId);

      // 🔔 Notify backend (accept)
      await groupDomain.groupRepository.respondToInvite(
        groupId: group.id,
        userId: user.id,
        accepted: true,
      );

      // 🔁 Refresh state
      final freshUser = await userDomain.getUser();
      if (freshUser != null) {
        userDomain.setCurrentUser(freshUser);
        await groupDomain.fetchAndInitializeGroups(freshUser.groupIds);
      }

      // 🧹 Remove notification (backend + local)
      await notificationService.deleteNotification(notification.id);
      await notificationDomain.removeNotificationById(
        notification.id,
        userDomain,
      );
    } catch (e) {
      devtools.log('❌ Error confirming invitation: $e');
    }
  }

  /// ✅ Handle "Decline" response to a group invite
  Future<void> handleNegation(NotificationUser notification) async {
    try {
      final group =
          await groupDomain.groupRepository.getGroupById(notification.groupId);
      final user = await userDomain.getUserById(notification.recipientId);

      // 🔔 Notify backend (decline)
      await groupDomain.groupRepository.respondToInvite(
        groupId: group.id,
        userId: user.id,
        accepted: false,
      );

      // 🔁 Refresh state
      final freshUser = await userDomain.getUser();
      if (freshUser != null) {
        userDomain.setCurrentUser(freshUser);
        await groupDomain.fetchAndInitializeGroups(freshUser.groupIds);
      }

      // 🧹 Remove notification (backend + local)
      await notificationService.deleteNotification(notification.id);
      await notificationDomain.removeNotificationById(
        notification.id,
        userDomain,
      );
    } catch (e) {
      devtools.log('❌ Error declining invitation: $e');
    }
  }

  /// ✅ Remove a notification by its index in the local list
  Future<void> removeNotificationByIndex(int index) async {
    final notification = notificationDomain.notifications[index];
    await notificationService.deleteNotification(notification.id);
    await notificationDomain.removeNotificationByIndex(index, userDomain);
  }

  /// ✅ Remove all notifications for the current user (DB + local)
  Future<void> removeAllNotifications(User user) async {
    try {
      await notificationService.deleteAllMine(); // backend
      notificationDomain.clearNotifications(); // local
      // Optional: re-fetch to ensure sync
      await fetchAndUpdateNotifications(user);
    } catch (e) {
      devtools.log('❌ Error removing all notifications: $e');
      rethrow;
    }
  }
}
