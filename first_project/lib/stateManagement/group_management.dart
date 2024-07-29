import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/node_services/group_services.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:first_project/utilities/notification_formats.dart';
import 'package:flutter/material.dart';

class GroupManagement extends ChangeNotifier {
  List<Group> _groups = [];
  final GroupService groupService = GroupService();
  final UserService userService = UserService();
  // final NotificationManagement notificationManagement;
  final UserManagement userManagement;
  final _groupController = StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get groupStream => _groupController.stream;

  User? currentUser; // Allow nullable currentUser

  Group? _currentGroup;
  Group? get currentGroup => _currentGroup;
  List<Group> get groups => _groups;

  GroupManagement({
    required User? user,
    // required this.notificationManagement,
    required this.userManagement,
  }) {
    if (user != null) {
      currentUser = user; // Initialize currentUser
      _initializeGroups(user);
    }
  }

  void setCurrentUser(User? user) {
    currentUser = user;
    if (user != null) {
      _initializeGroups(user);
    }
    notifyListeners();
  }

  Future<void> _initializeGroups(User user) async {
    await _fetchAndInitializeGroups(user);
  }

  Future<void> _fetchAndInitializeGroups(User user) async {
    try {
      List<Group> groups = [];
      for (String groupId in user.groupIds) {
        Group group = await groupService.getGroupById(groupId);
        groups.add(group);
      }
      updateGroupStream(groups);
    } catch (e) {
      print('Failed to fetch and initialize groups: $e');
    }
  }

  void updateGroupStream(List<Group> groups) {
    _groups = groups;
    _groupController.add(groups);
    notifyListeners();
  }

  set currentGroup(Group? group) {
    _currentGroup = group;
    notifyListeners();
  }

  Future<bool> addGroup(
      Group group, NotificationManagement notificationManagement) async {
    // if (currentUser == null) {
    //   print('Current user is not set.');
    //   return false;
    // }

    try {
      // Create the group in the group service
      await groupService.createGroup(group);

      // Update local state
      _groups.add(group);
      _groupController.add(_groups);
      notifyListeners();

      // Fetch the current user from the user service
      User user = await userService.getUserByUsername(currentUser!.userName);

      // Add the group ID to the current user's groupIds
      user.groupIds.add(group.id);

      // Create a notification for the current user
      NotificationFormats notificationFormat = NotificationFormats();
      NotificationUser userNotification =
          notificationFormat.whenCreatingGroup(group, user);

      // Check for duplicates before adding
      if (!notificationFormat.isDuplicateNotification(
          user.notifications, userNotification)) {
        user.notifications.add(userNotification);
        user.hasNewNotifications = true;
      }

      // Save the notification to the database
      await notificationManagement.addNotification(userNotification, user, userManagement);

      // Send invitations to invited users
      for (final userName in group.invitedUsers!.keys) {
        // Fetch the invited user from the user service
        User invitedUser = await userService.getUserByUsername(userName);

        // Create a group invitation notification for the invited user
        NotificationUser invitedUserNotification =
            notificationFormat.createGroupInvitation(group, invitedUser);

        // Check for duplicates before adding
        if (!notificationFormat.isDuplicateNotification(
            invitedUser.notifications, invitedUserNotification)) {
          invitedUser.notifications.add(invitedUserNotification);
          invitedUser.hasNewNotifications = true;
        }

        // Save the notification to the database
        await notificationManagement.addNotification(
            invitedUserNotification, invitedUser, userManagement);
      }

      devtools.log("Updated user = ${user.toString()}");
      return true;
    } catch (e) {
      print('Failed to add group: $e');
      return false;
    }
  }

  Future<void> updateGroup(Group updateGroup) async {
    if (currentUser == null) {
      print('Current user is not set.');
      return;
    }

    final notificationFormat = NotificationFormats();
    NotificationUser editingNotification = notificationFormat.whenEditingGroup(
        updateGroup, userManagement.currentUser!);

    // Retrieve the user's role using their ID from group.userRoles
    String? userRole = updateGroup.userRoles[userManagement.currentUser!.id];

    // Check if user has "Administration" or "Co-Administrator" roles
    if (userRole == 'Administration' || userRole == 'Co-Administrator') {
      // Check for duplicates before adding
      if (!notificationFormat.isDuplicateNotification(
          userManagement.currentUser!.notifications, editingNotification)) {
        userManagement.currentUser!.notifications.add(editingNotification);
        await userService.updateUser(userManagement.currentUser!);
      }
    }

    for (final userName in updateGroup.invitedUsers!.keys) {
      final user = await userService.getUserByUsername(userName);
      notificationFormat.createGroupInvitation(updateGroup, user);

      NotificationUser newUserHasBeenAdded = notificationFormat
          .newUserHasBeenAdded(updateGroup, userManagement.currentUser!);

      // Check for duplicates before adding
      if (!notificationFormat.isDuplicateNotification(
          user.notifications, newUserHasBeenAdded)) {
        user.notifications.add(newUserHasBeenAdded);
        await userService.updateUser(user);
      }
    }

    await groupService.updateGroup(updateGroup.id, updateGroup);
    _currentGroup = updateGroup;

    final index = _groups.indexWhere((g) => g.id == updateGroup.id);
    if (index != -1) {
      _groups[index] = updateGroup;
      _groupController.add(_groups); // Add updated groups to the stream
      notifyListeners();
    }
  }

  Future<bool> removeGroup(Group group) async {
    try {
      await groupService.deleteGroup(group.id);
      _groups.removeWhere((g) => g.id == group.id);
      _groupController.add(_groups);
      notifyListeners();
      currentUser?.groupIds.remove(group.id); // Handle nullable currentUser
      // Additional logic for updating user
      return true;
    } catch (e) {
      print('Failed to remove group: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _groupController.close();
    super.dispose();
  }
}
