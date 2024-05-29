import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/node_services/group_services.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:first_project/utilities/notification_formats.dart';
import 'package:flutter/material.dart';

class ProviderManagement extends ChangeNotifier {
  User? _currentUser;
  List<Group> _groups = [];
  List<NotificationUser> _notifications = [];
  ThemeData _themeData = lightTheme;
  late NotificationFormats notification;
  late NotificationUser notificationUser;
  final UserService userService = UserService();
  final GroupService groupService = GroupService();

  // Getters
  User? get currentUser => _currentUser;
  ThemeData get themeData => _themeData;

  //** CONTROLLER FOR MY GROUPS  */
  // Stream controller and stream for group updates
  final _groupController = StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get groupStream => _groupController.stream;

  ProviderManagement({required User? user}) {
    _currentUser = user;
    if (user != null) {
      _notifications = user.notifications;
    } else {
      _notifications = [];
    }
  }

  //** GROUPS FUNCTIONS  */
  // Method to update the group stream with the latest list of groups
  void updateGroupStream(List<Group> groups) {
    _groupController.add(groups);
    notifyListeners();
  }

  Future<bool> getUser() async {
    try {
      await userService.getUserByUsername(_currentUser!.userName);
      return true;
    } catch (e) {
      print('Failed to get User: $e');
      return false;
    }
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void initialize(User user, List<Group> groups) {
    _currentUser = user;
    _groups.addAll(groups);
    _groupController.add(_groups); // Add initial groups to the stream
    notifyListeners();
  }

  Future<bool> updateUser(User newUser) async {
    try {
      // await userService.updateUserByUsername(newUser.userName,newUser);
      await userService.updateUser(newUser);
      if (newUser.id == _currentUser!.id) {
        _currentUser = newUser;
      }
      notifyListeners();
      return true;
    } catch (e) {
      print('Failed update the user: $e');
      return false;
    }
  }

  Future<bool> addGroup(Group group) async {
    try {
      await groupService.createGroup(group);
      _groups.add(group);
      _groupController.add(_groups); // Add updated groups to the stream
      notifyListeners();

      //!UPDATE USER
      User user = await userService.getUserByUsername(_currentUser!.userName);
      //Now we need to update the user, we need to add the user to the group
      user.groupIds.add(group.id);
      // We also need to create a notification for the user
      notification = NotificationFormats();
      notificationUser = notification.whenCreatingGroup(group, _currentUser!);
      user.notifications.add(notificationUser);
      user.hasNewNotifications = true;
      addNotification(notificationUser);
      devtools.log("Updated user = ${user.toString()}");
      await updateUser(user);
      return true;
    } catch (e) {
      print('Failed to add group: $e');
      return false;
    }
  }

  Future<bool> removeGroup(Group group) async {
    try {
      await groupService.deleteGroup(group.id);
      _groups.removeWhere((g) => g.id == group.id);
      _groupController.add(_groups); // Add updated groups to the stream
      notifyListeners();
      // _currentUser!.groupIds.remove(group.id);
      // await updateUser(_currentUser!);
      return true;
    } catch (e) {
      print('Failed to add group: $e');
      return false;
    }
  }

  void updateGroup(Group updateGroup) async {
    // bool isAdmin =
    //     beforeUpdating.userRoles.containsKey(_currentUser!.userName) &&
    //         beforeUpdating.userRoles[_currentUser!.userName] == 'Administrator';
    notification = NotificationFormats();
    notification.whenEditingGroup(updateGroup, _currentUser!);
    _currentUser!.notifications.add(notification);
    await userService.updateUser(_currentUser!);

    // Loop through each user ID in the invitedUsers map
    for (final userName in updateGroup.invitedUsers!.keys) {
      User? user = await userService.getUserByUsername(userName);
      notification.createGroupInvitation(updateGroup, user);
      user.notifications.add(notification);
      //Now we proceed to update the users
      await updateUser(user);
    }

    await groupService.updateGroup(updateGroup.id, updateGroup);
    final index = _groups.indexWhere((g) => g.id == updateGroup.id);
    if (index != -1) {
      _groups[index] = updateGroup;
      _groupController.add(_groups); // Add updated groups to the stream
      notifyListeners();
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
    notifyListeners();
  }

  //** NOTIFICATION FUNCTIONS */

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
