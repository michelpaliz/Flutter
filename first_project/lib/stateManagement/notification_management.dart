import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/notification_user.dart';
import 'package:first_project/services/node_services/notification_services.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:flutter/material.dart';

class NotificationManagement extends ChangeNotifier {
  List<NotificationUser> _notifications = [];
  final NotificationService notificationService = NotificationService();
  final _notificationController =
      StreamController<List<NotificationUser>>.broadcast();
  Stream<List<NotificationUser>> get notificationStream =>
      _notificationController.stream;

  List<NotificationUser> get notifications => _notifications;

  void initNotifications(List<NotificationUser> initialNotifications) {
    _notifications = _sortNotificationsByDate(initialNotifications);
    _notificationController.add(_notifications);
    notifyListeners();
  }

  void updateNotificationStream(List<NotificationUser> notifications) {
    _notifications = _sortNotificationsByDate(notifications);
    _notificationController.add(_notifications);
    notifyListeners();
  }

  List<NotificationUser> _sortNotificationsByDate(
      List<NotificationUser> notifications) {
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  Future<void> markNotificationsAsRead() async {
    try {
      List<NotificationUser> updatedNotifications = [];
      for (NotificationUser notification in _notifications) {
        if (!notification.isRead) {
          notification.isRead = true;
          devtools.log("This is notification: " + notification.toString());
          await notificationService.updateNotification(notification);
        }
        var notificationUpdated =
            await notificationService.getNotificationById(notification.id);
        updatedNotifications.add(notificationUpdated);
      }
      _notifications = _sortNotificationsByDate(updatedNotifications);
      _notificationController.add(_notifications);
      notifyListeners();
    } catch (e) {
      print('Failed to mark notifications as read: $e');
    }
  }

  Future<bool> removeNotificationByIndex(
      int index, UserManagement userManagement) async {
    if (index < 0 || index >= _notifications.length) {
      print('Index out of range');
      return false;
    }

    try {
      NotificationUser notification = _notifications[index];

      // Remove the notification from the local list
      _notifications.removeAt(index);
      _notifications = _sortNotificationsByDate(_notifications);

      // Update the user notifications list
      userManagement.currentUser!.notifications.removeWhere((n) => n.id == notification.id);

      // Update the user in the database
      // await userService.updateUser(user);
      await userManagement.updateUser(userManagement.currentUser!);

      // Update the notification stream
      _notificationController.add(_notifications);
      notifyListeners();

      // Also remove from the backend
      await notificationService.deleteNotification(notification.id);

      return true;
    } catch (e) {
      print('Failed to remove notification: $e');
      return false;
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _notificationController.add(_notifications);
    notifyListeners();
  }

  Future<void> addNotification(NotificationUser notification, user,
      UserManagement userManagement) async {
    try {
      await notificationService.createNotification(notification);
      // await userService.updateUser(user);
      await userManagement.updateUser(user);
      if (user.id == notification.ownerId) {
        _notifications.add(notification);
        _notifications = _sortNotificationsByDate(_notifications);
        _notificationController.add(_notifications);
      }
      notifyListeners();
    } catch (e) {
      print('Failed to add notification: $e');
    }
  }

  @override
  void dispose() {
    _notificationController.close();
    super.dispose();
  }
}
