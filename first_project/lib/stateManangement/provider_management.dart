import 'dart:async';

import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:flutter/material.dart';

class ProviderManagement extends ChangeNotifier {
  User? _currentUser;
  List<Group> _groups = [];
  List<NotificationUser> _notifications = [];
  ThemeData _themeData = lightTheme;

  // Getters
  User? get currentUser => _currentUser;
  List<Group> get groups => _groups;
  ThemeData get themeData => _themeData;

  //** CONTROLLER FOR MY GROUPS  */
  // Stream controller and stream for group updates
  final _groupController = StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get groupStream => _groupController.stream;

  ProviderManagement({required User? user}) {
    _currentUser = user;
    // initNotifications(_currentUser!.notifications);
  }

  //** GROUPS FUNCTIONS  */
  // Method to update the group stream with the latest list of groups
  void updateGroupStream(List<Group> groups) {
    _groupController.add(groups);
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void initialize(User user, List<Group> groups) {
    _currentUser = user;
    _groups.addAll(groups);
    notifyListeners();
    _groupController.add(_groups); // Add initial groups to the stream
  }

  void updateUser(User newUser) {
    _currentUser = newUser;
    notifyListeners();
  }

  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
    _groupController.add(_groups); // Add updated groups to the stream
  }

  void removeGroup(Group group) {
    _groups.removeWhere((g) => g.id == group.id);
    notifyListeners();
    _groupController.add(_groups); // Add updated groups to the stream
  }

  void updateGroup(Group updatedGroup) {
    final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
      _groupController.add(_groups); // Add updated groups to the stream
    }
  }

  void toggleTheme() {
    _themeData = (_themeData == lightTheme) ? darkTheme : lightTheme;
    notifyListeners();
  }

  //** CONTROLLER FOR MY NOTIFICATIONS */

  final _notificationController =
      StreamController<List<NotificationUser>>.broadcast();

  Stream<List<NotificationUser>> get notificationStream =>
      _notificationController.stream;
  List<NotificationUser> get notifications => _notifications;

  void updateNotificationStream(List<NotificationUser> notifications) {
    _notificationController.add(notifications);
    _notifications = (notifications);
  }

  //** NOTIFICATION FUNCTIONS */

  // // Initialize notifications for the current user
  // void initNotifications(List<NotificationUser> notifications) {
  //   _notifications.addAll(notifications);
  //   _notificationController
  //       .add(_notifications); // Add initial notifications to the stream
  // }

  // Methods to update notifications
  void addNotification(NotificationUser notification) {
    _notifications.add(notification);
    _notificationController
        .add(_notifications); // Add updated notifications to the stream
    notifyListeners();
  }

  void removeNotification(NotificationUser notification) {
    _notifications.remove(notification);
    _notificationController
        .add(_notifications); // Add updated notifications to the stream
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _notificationController
        .add(_notifications); // Add updated notifications to the stream
    notifyListeners();
  }

  // Dispose the stream controller when no longer needed
  @override
  void dispose() {
    _groupController.close();
    _notificationController
        .close(); // Dispose the notification stream controller
    super.dispose();
  }
}
