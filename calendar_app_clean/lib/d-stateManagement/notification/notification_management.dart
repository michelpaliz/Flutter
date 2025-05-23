import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/b-backend/api/notification/notification_services.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';

class NotificationManagement extends ChangeNotifier {
  List<NotificationUser> _notifications = [];
  List<String> _notificationIds = []; // Store IDs only
  final NotificationService notificationService = NotificationService();
  final _notificationController =
      StreamController<List<NotificationUser>>.broadcast();

  Stream<List<NotificationUser>> get notificationStream =>
      _notificationController.stream;

  List<NotificationUser> get notifications => _notifications;
  List<String> get notificationIds => _notificationIds;

  // Initialize notifications with IDs, fetch full NotificationUser objects
  Future<void> initNotifications(List<String> notificationIds) async {
    _notificationIds = notificationIds;
    _notifications = await _fetchNotificationsByIds(notificationIds);
    _notifications = _sortNotificationsByDate(_notifications);
    _notificationController.add(_notifications);
    notifyListeners();
  }

  // Fetch full NotificationUser objects based on IDs
  Future<List<NotificationUser>> _fetchNotificationsByIds(
      List<String> ids) async {
    List<NotificationUser> notifications = [];
    for (String id in ids) {
      NotificationUser? notification =
          await notificationService.getNotificationById(id);
      notifications.add(notification); // No need for DTO conversion
    }
    return notifications;
  }

  // Update notification stream
  Future<void> updateNotificationStream(
      List<NotificationUser> notifications) async {
    _notifications = _sortNotificationsByDate(notifications);
    _notificationController.add(_notifications);
    notifyListeners();
  }

  // Sort notifications by date
  List<NotificationUser> _sortNotificationsByDate(
      List<NotificationUser> notifications) {
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  // Mark notifications as read, update both locally and on the service level
  Future<void> markAllNotificationsAsRead(UserManagement userManagement) async {
    try {
      List<String> updatedNotificationIds = [];
      for (NotificationUser notification in _notifications) {
        if (!notification.isRead) {
          notification.isRead = true; // Mark as read directly
          await notificationService.updateNotification(notification);
          updatedNotificationIds.add(notification.id);
        }
      }
      _notificationIds = updatedNotificationIds;
      _notifications = await _fetchNotificationsByIds(updatedNotificationIds);
      userManagement.user?.notifications =
          _notificationIds; // Store IDs in user object
      await userManagement.updateUser(userManagement.user!);

      _notificationController.add(_notifications);
      notifyListeners();
    } catch (e) {
      print('Failed to mark notifications as read: $e');
    }
  }

  // Remove notification by index
  Future<bool> removeNotificationByIndex(
      int index, UserManagement userManagement) async {
    if (index < 0 || index >= _notifications.length) {
      return false;
    }

    try {
      NotificationUser notification = _notifications[index];
      _notifications.removeAt(index);
      _notificationIds.remove(notification.id); // Remove the ID

      userManagement.user?.notifications = _notificationIds;
      await userManagement.updateUser(userManagement.user!);

      _notificationController.add(_notifications);
      notifyListeners();

      return true;
    } catch (e) {
      print('Failed to remove notification: $e');
      return false;
    }
  }

  // Remove notification by ID
  Future<bool> removeNotificationById(
      String notificationId, UserManagement userManagement) async {
    try {
      _notificationIds.remove(notificationId);
      _notifications
          .removeWhere((notification) => notification.id == notificationId);

      userManagement.user?.notifications = _notificationIds;
      await userManagement.updateUser(userManagement.user!);

      _notificationController.add(_notifications);
      notifyListeners();

      return true;
    } catch (e) {
      print('Failed to remove notification: $e');
      return false;
    }
  }

  // Method to update user notification IDs
  Future<void> updateUserNotificationIds(
      List<String> newNotificationIds, UserManagement userManagement) async {
    try {
      // Update the internal list of notification IDs
      _notificationIds = newNotificationIds;

      // Fetch the updated notifications from the service
      _notifications = await _fetchNotificationsByIds(newNotificationIds);

      // Sort the notifications by date
      _notifications = _sortNotificationsByDate(_notifications);

      // Update the current user's notification IDs
      userManagement.user?.notifications = newNotificationIds;

      // Update the user object in the database or state management
      await userManagement.updateUser(userManagement.user!);

      // Update the notification stream with the new notifications
      _notificationController.add(_notifications);

      // Notify listeners to refresh the UI
      notifyListeners();
    } catch (e) {
      devtools.log('Failed to update user notification IDs: $e');
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _notificationIds.clear();
    _notificationController.add(_notifications);
    notifyListeners();
  }

  @override
  void dispose() {
    _notificationController.close();
    super.dispose();
  }
}
