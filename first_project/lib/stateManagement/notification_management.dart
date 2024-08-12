import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
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
    devtools.log('Attempting to remove notification at index: $index');
    devtools.log('Current notifications length: ${_notifications.length}');

    if (index < 0 || index >= _notifications.length) {
      devtools.log('Index out of range');
      return false;
    }

    try {
      NotificationUser notification = _notifications[index];
      devtools.log('Notification to remove: ${notification.id}');

      _notifications.removeAt(index);
      devtools.log('Notification removed from _notifications list');

      userManagement.currentUser?.notifications = _notifications;
      // userManagement.currentUser!.notifications.removeWhere((n) => n.id == notification.id);
      devtools.log(
          'Notification removed from userManagement.currentUser!.notifications');

      await userManagement.updateUser(userManagement.currentUser!);
      devtools.log(
          'User updated successfully ${userManagement.currentUser?.notifications}');

      _notificationController.add(_notifications);
      notifyListeners();

      devtools.log('Notification removed successfully');
      return true;
    } catch (e) {
      devtools.log('Failed to remove notification: $e');
      return false;
    }
  }

  /// New function to remove a notification by its ID
  Future<bool> removeNotificationById(
      String notificationId, UserManagement userManagement) async {
    devtools.log('Attempting to remove notification with ID: $notificationId');

    try {
      // Find the index of the notification with the given ID
      int index = _notifications.indexWhere((ntf) => ntf.id == notificationId);

      if (index == -1) {
        devtools.log('Notification with ID $notificationId not found');
        return false;
      }

      NotificationUser notification = _notifications[index];
      devtools.log('Notification to remove: ${notification.id}');

      // Remove the notification
      _notifications.removeAt(index);
      devtools.log('Notification removed from _notifications list');

      // Update the user's notifications
      userManagement.currentUser?.notifications = _notifications;
      devtools.log(
          'Notification removed from userManagement.currentUser!.notifications');

      // Persist the user update
      await userManagement.updateUser(userManagement.currentUser!);
      devtools.log(
          'User updated successfully ${userManagement.currentUser?.notifications}');

      // Update the notification stream
      _notificationController.add(_notifications);
      notifyListeners();

      devtools.log('Notification removed successfully');
      return true;
    } catch (e) {
      devtools.log('Failed to remove notification: $e');
      return false;
    }
  }

  Future<bool> addNotification(
      NotificationUser notification, UserManagement userManagement) async {
    try {
      User admin =
          await userManagement.userService.getUserById(notification.senderId);
      User invitedUser = await userManagement.userService
          .getUserById(notification.recipientId);

      User? updateUser;
      if (admin.id == notification.recipientId) {
        updateUser = admin;
      } else {
        updateUser = invitedUser;
        updateUser.notifications.add(notification);
      }

      // Create the notification in the service
      await notificationService.createNotification(notification);

      //!this will cause duplicate notifications
      // Add the notification to the user's list
      // updateUser.notifications.add(notification);

      // Update the user with the new notification
      await userManagement.updateUser(updateUser);

      // Update the notification stream
      if (updateUser.id == userManagement.currentUser!.id) {
        _notifications.add(notification);
        _notifications = _sortNotificationsByDate(_notifications);
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('Failed to add notification: $e');
      return false;
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _notificationController.add(_notifications);
    notifyListeners();
  }

  // Future<bool> addNotificationForInvitedUser(NotificationUser notification,
  //     User user, UserManagement userManagement) async {
  //   try {
  //     // Create the notification using the service
  //     await notificationService.createNotification(notification);

  //     // Update the user with the new notification
  //     List<NotificationUser> updatedNotificationList =
  //         _sortNotificationsByDate([...user.notifications, notification]);
  //     user.notifications = updatedNotificationList;

  //     bool userUpdateSuccess = await userManagement.updateUser(user);
  //     if (!userUpdateSuccess) {
  //       print('Failed to update user: ${user.id}');
  //       return false;
  //     }

  //     // Update the global notifications stream if the user is the owner of the notification
  //     if (user.id == notification.ownerId) {
  //       _notifications.add(notification);
  //       _notifications =
  //           _sortNotificationsByDate([..._notifications, notification]);
  //       _notificationController.add(_notifications);
  //     }

  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     print('Error adding notification for invited user: $e');
  //     return false;
  //   }
  // }

  @override
  void dispose() {
    _notificationController.close();
    super.dispose();
  }
}
