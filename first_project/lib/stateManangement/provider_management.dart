import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/node_services/group_services.dart';
import 'package:first_project/services/node_services/notification_services.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:first_project/utilities/notification_formats.dart';
import 'package:flutter/material.dart';

class ProviderManagement extends ChangeNotifier {
  User? _currentUser;
  Group? _currentGroup;
  List<Group> _groups = [];
  List<NotificationUser> _notifications = [];
  ThemeData _themeData = lightTheme;
  late NotificationFormats notification;
  late NotificationUser notificationUser;
  final UserService userService = UserService();
  final GroupService groupService = GroupService();
  final NotificationService _notificationService = NotificationService();
  List<Group>? _currentGroups;

  // Getters
  User? get currentUser => _currentUser;
  Group? get currentGroup => _currentGroup;
  List<Group>? get currentGroups => _currentGroups;
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

  //Setters two ways to set the variables
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  set currentGroup(Group? group) {
    _currentGroup = group;
    notifyListeners();
  }

  set currentGroupList(List<Group>? groups) {
    _currentGroups = groups;
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
      await addNotification(notificationUser);
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
      _currentUser!.groupIds.remove(group.id);
      await updateUser(_currentUser!);
      return true;
    } catch (e) {
      print('Failed to add group: $e');
      return false;
    }
  }

  Future<void> updateGroup(Group updateGroup) async {
    // Create a notification for editing the group
    final notificationFormat = NotificationFormats();
    NotificationUser notification =
        notificationFormat.whenEditingGroup(updateGroup, _currentUser!);

    _currentUser!.notifications.add(notification);

    // Update the current user
    await userService.updateUser(_currentUser!);

    // Loop through each user ID in the invitedUsers map
    for (final userName in updateGroup.invitedUsers!.keys) {
      final user = await userService.getUserByUsername(userName);
      notificationFormat.createGroupInvitation(updateGroup, user);
      user.notifications.add(notification);

      // Now proceed to update the users
      await updateUser(user);
    }

    // Update the group
    await groupService.updateGroup(updateGroup.id, updateGroup);

    currentGroup = updateGroup;

    // Update the local list of groups
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
  Future<void> addNotification(NotificationUser notification) async {
    try {
      await _notificationService.createNotification(notification);
      await updateUser(_currentUser!);
      _notifications.add(notification);
      _notificationController
          .add(_notifications); // Add updated notifications to the stream
      notifyListeners();
    } catch (e) {
      print('Failed to add notification: $e');
    }
  }

  Future<bool> removeNotification(NotificationUser notification) async {
    try {
      var result =
          await _notificationService.deleteNotification(notification.id);
      if (result) {
        _currentUser!.notifications.remove(notification.id);
        await updateUser(_currentUser!);
        _notifications.remove(notification);
        _notificationController
            .add(_notifications); // Add updated notifications to the stream
        notifyListeners();
      }
      return true;
    } catch (e) {
      print('Failed to remove notification: $e');
      return false;
    }
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
