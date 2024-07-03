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
  final NotificationService notificationService = NotificationService();

  // Getters
  User? get currentUser => _currentUser;
  Group? get currentGroup => _currentGroup;
  List<Group> get groups => _groups;
  ThemeData get themeData => _themeData;

  // Controllers for streams
  final _userController = StreamController<User?>.broadcast();
  Stream<User?> get userStream => _userController.stream;

  final _groupController = StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get groupStream => _groupController.stream;

  final _notificationController =
      StreamController<List<NotificationUser>>.broadcast();
  Stream<List<NotificationUser>> get notificationStream =>
      _notificationController.stream;
  List<NotificationUser> get notifications => _notifications;

  ProviderManagement({required User? user}) {
    _currentUser = user;
    if (user != null) {
      _initializeGroups();
      // fetchUserNotifications(_currentUser!.name);
      // // _initializeNotifications(user.notifications);
    } else {
      _notifications = [];
    }
  }

  // Method to update _currentUser and add it to the stream
  void updateCurrentUser(User? user) {
    _currentUser = user;
    _userController.add(user);
    notifyListeners();
  }

  // Method to initialize groups
  Future<void> _initializeGroups() async {
    if (_currentUser != null) {
      await _fetchAndInitializeGroups();
    }
  }

  // Fetch and initialize groups from the service
  Future<void> _fetchAndInitializeGroups() async {
    try {
      List<Group> groups = [];
      for (String groupId in _currentUser!.groupIds) {
        Group group = await groupService.getGroupById(groupId);
        groups.add(group);
      }
      updateGroupStream(groups);
    } catch (e) {
      print('Failed to fetch and initialize groups: $e');
    }
  }

  // Method to update the group stream with the latest list of groups
  void updateGroupStream(List<Group> groups) {
    _groups.clear();
    _groups = groups;
    _groupController.add(groups);

    if (groups.isEmpty) {
      _currentGroup =
          null; // Handle empty groups list by setting _currentGroup to null
    } else if (_currentGroup != null) {
      try {
        _currentGroup =
            groups.firstWhere((group) => group.id == _currentGroup!.id);
      } catch (e) {
        _currentGroup =
            null; // If the current group is not found, set _currentGroup to null
      }
    }

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

  Future<void> updateCostumeUser(User? userUpdated) async {
    if (userUpdated != null) {
      _currentUser = userUpdated;
    } else {
      return;
    }

    if (userUpdated.email.isNotEmpty) {
      try {
        final userFromService =
            await userService.getUserByEmail(userUpdated.email);
        _currentUser = userFromService;
        updateCurrentUser(_currentUser);
      } catch (e) {
        print('Failed to update user: $e');
      }
    }
    notifyListeners();
  }

  void setCurrentUser(User? user) {
    updateCostumeUser(user);
  }

  set currentGroup(Group? group) {
    _currentGroup = group;
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
      // Create the group in the group service
      await groupService.createGroup(group);

      // Update local state
      _groups.add(group);
      _groupController.add(_groups);
      notifyListeners();

      // Fetch the current user from the user service
      User user = await userService.getUserByUsername(_currentUser!.userName);

      // Add the group ID to the current user's groupIds
      user.groupIds.add(group.id);

      // Create a notification for the current user
      NotificationFormats notificationFormat = NotificationFormats();
      NotificationUser userNotification =
          notificationFormat.whenCreatingGroup(group, user);
      user.notifications.add(userNotification);
      user.hasNewNotifications = true;

      List<NotificationUser> _notifications = user.notifications;

      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      user.notifications = _notifications;

      // Save the notification to the database
      await _addNotification(userNotification, user);

      // Send invitations to invited users
      for (final userName in group.invitedUsers!.keys) {
        // Fetch the invited user from the user service
        User invitedUser = await userService.getUserByUsername(userName);

        // Create a group invitation notification for the invited user
        NotificationUser invitedUserNotification =
            notificationFormat.createGroupInvitation(group, invitedUser);
        invitedUser.notifications.add(invitedUserNotification);
        invitedUser.hasNewNotifications = true;

        List<NotificationUser> _notifications = invitedUser.notifications;

        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        invitedUser.notifications = _notifications;

        // Save the notification to the database
        await _addNotification(invitedUserNotification, invitedUser);
      }

      devtools.log("Updated user = ${user.toString()}");
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
    final notificationFormat = NotificationFormats();
    NotificationUser notification =
        notificationFormat.whenEditingGroup(updateGroup, _currentUser!);

    _currentUser!.notifications.add(notification);
    await userService.updateUser(_currentUser!);

    for (final userName in updateGroup.invitedUsers!.keys) {
      final user = await userService.getUserByUsername(userName);
      notificationFormat.createGroupInvitation(updateGroup, user);
      user.notifications.add(notification);
      await updateUser(user);
    }

    await groupService.updateGroup(updateGroup.id, updateGroup);

    currentGroup = updateGroup;

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

  void updateNotificationStream(List<NotificationUser> notifications) {
    _notificationController.add(notifications);
    _notifications = notifications;
    notifyListeners();
  }

  Future<void> _addNotification(
      NotificationUser notification, User user) async {
    try {
      await notificationService.createNotification(notification);
      await updateUser(user);
      // _notifications.add(notification);
      if (_currentUser!.id == notification.ownerId) {
        updateNotificationStream(
            notifications); // Add updated notifications to the stream
      }
      notifyListeners();
    } catch (e) {
      print('Failed to add notification: $e');
    }
  }

  Future<bool> removeNotification(NotificationUser notification) async {
    try {
      var result =
          await notificationService.deleteNotification(notification.id);
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

  @override
  void dispose() {
    _groupController.close();
    _notificationController.close();
    super.dispose();
  }

  void logout() {
    _currentGroup = null;
    _groups = [];
    _notifications = [];
    _userController.add(null);
    _groupController.add([]);
    _notificationController.add([]);
    notifyListeners();
  }
}
