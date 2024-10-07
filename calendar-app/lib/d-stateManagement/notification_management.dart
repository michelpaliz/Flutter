import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/model/DTO/notificationDTO.dart';
import 'package:first_project/a-models/model/user_data/notification_user.dart';
import 'package:first_project/b-backend/database_conection/node_services/notification_services.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
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
  List<String> get notificationsIds => _notificationIds;

  // Initialize notifications with IDs, resolve them to full NotificationUser objects if needed
  Future<void> initNotifications(List<String> notifications) async {
    _notificationIds = notifications;
    _notifications = await _fetchNotificationsByIds(notifications);
    _notifications = _sortNotificationsByDate(_notifications);
    _notificationController.add(_notifications);
    notifyListeners();
  }

  // Fetch full NotificationUser objects based on IDs and convert from DTO
  Future<List<NotificationUser>> _fetchNotificationsByIds(
      List<String> ids) async {
    List<NotificationUser> notifications = [];
    for (String id in ids) {
      NotificationUserDTO? notificationDTO =
          await notificationService.getNotificationById(id);
      notifications.add(NotificationUser.fromDTO(notificationDTO));
    }
    return notifications;
  }

  // Update notification stream (used when notifications change)
  Future<void> updateNotificationStream(List<NotificationUser> notifications) async {
    // _notificationIds = notifications;
    // _notifications = await _fetchNotificationsByIds(notifications);
    _notifications = _sortNotificationsByDate(_notifications);
    _notificationController.add(_notifications);
    notifyListeners();
  }

  List<NotificationUser> _sortNotificationsByDate(
      List<NotificationUser> notifications) {
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  // Mark notifications as read, update both on user and service level
  Future<void> markNotificationsAsRead(UserManagement userManagement) async {
    try {
      List<String> updatedNotificationIds = [];
      for (NotificationUser notification in _notifications) {
        if (!notification.isRead) {
          final updatedNotificationDTO =
              NotificationUserDTO.fromNotification(notification);
          await notificationService.updateNotification(updatedNotificationDTO);
          updatedNotificationIds.add(updatedNotificationDTO.id);
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

  // Remove notification by index (use ID-based approach)
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

  // Add notification to the DB
  Future<bool> addNotificationToDB(
      NotificationUser notification, UserManagement userManagement) async {
    try {
      // Convert NotificationUser to NotificationUserDTO for saving
      final notificationDTO =
          NotificationUserDTO.fromNotification(notification);
      // Create the notification in the service
      await notificationService.createNotification(notificationDTO);

      _notificationIds.add(notification.id);
      if (userManagement.user?.id == notification.recipientId) {
        _notifications.add(notification);
        _notifications = _sortNotificationsByDate(_notifications);
        notifyListeners();
      }

      userManagement.user?.notifications = _notificationIds;
      await userManagement.updateUser(userManagement.user!);

      return true;
    } catch (e) {
      print('Failed to add notification: $e');
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
