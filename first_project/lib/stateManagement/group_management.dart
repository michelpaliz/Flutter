import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';
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
  final _groupController = StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get groupStream => _groupController.stream;

  User? currentUser; // Allow nullable currentUser

  Group? _currentGroup;
  Group? get currentGroup => _currentGroup;
  List<Group> get groups => _groups;

  GroupManagement({
    required User? user,
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
      Group group,
      NotificationManagement notificationManagement,
      UserManagement userManagement) async {
    try {
      // Create the group in the group service
      await groupService.createGroup(group);

      // Update local state
      _groups.add(group);
      _groupController.add(_groups);
      notifyListeners();

      // Fetch the current user from the user service
      User user = await userService
          .getUserByUsername(userManagement.currentUser!.userName);

      // Add the group ID to the current user's groupIds
      user.groupIds.add(group.id);

      // Create a notification for the current user
      NotificationFormats notificationFormat = NotificationFormats();
      NotificationUser userNotification =
          notificationFormat.whenCreatingGroup(group, user);

      // Check for duplicates before adding
      user.notifications.add(userNotification);
      user.hasNewNotifications = true;

      // Save the notification to the database
      // await notificationManagement.addNotification(
      //     userNotification, userManagement, null);

      await notificationManagement.addNotification(
          userNotification, userManagement);

      bool result = await _notifyUserInvitation(
          group, notificationManagement, userManagement, group.invitedUsers);

      if (result) {
        userManagement.updateUser(user);
        devtools.log("Group added = ${user.toString()}");
      } else {
        devtools.log("Group couldn't be added = ${user.toString()}");
      }

      return true;
    } catch (e) {
      print('Failed to add group: $e');
      return false;
    }
  }

  Future<bool> _notifyUserInvitation(
      Group group,
      NotificationManagement notificationManagement,
      UserManagement userManagement,
      Map<String, UserInviteStatus>? invitedUsers) async {
    final notificationFormat = NotificationFormats();

    try {
      for (final userName in invitedUsers!.keys) {
        // Retrieve the invited user
        final invitedUser = await userService.getUserByUsername(userName);

        // Create a group invitation notification
        NotificationUser invitationNotification =
            notificationFormat.createGroupInvitation(group, invitedUser);

        devtools.log(
            "Created invitation notification for $userName: $invitationNotification");

        // Check for duplicates and remove if found
        bool isDuplicate = NotificationFormats.isDuplicateNotification(
            invitedUser.notifications, invitationNotification);

        if (isDuplicate) {
          invitedUser.notifications.removeWhere(
              (notification) => notification.id == invitationNotification.id);
          print('Removed duplicate notification for user $userName');
        }
        // Add the new notification
        invitedUser.notifications.add(invitationNotification);
        print('Added notification for user $userName');

        // Add the notification to the NotificationManagement system
        // bool notificationSuccess = await notificationManagement.addNotification(
        //     invitationNotification, userManagement, invitedUser);
        bool notificationSuccess = await notificationManagement.addNotification(
            invitationNotification, userManagement);
        if (!notificationSuccess) {
          print('Failed to add notification for user: $userName');
          return false;
        }

        // Update the user with the new notification
        bool userUpdateSuccess = await userManagement.updateUser(invitedUser);
        if (!userUpdateSuccess) {
          print('Failed to update user: $userName');
          return false;
        }
      }

      // Update the group in the service
      await groupService.updateGroup(group);

      // Update the current group locally
      _currentGroup = group;

      // Update the groups list and notify listeners
      final index = _groups.indexWhere((g) => g.id == group.id);
      if (index != -1) {
        _groups[index] = group;
      } else {
        _groups.add(group);
      }
      _groupController
          .add(_groups); // Update the stream with the new groups list
      notifyListeners();

      return true;
    } catch (e) {
      print('Failed to notify users for invitation: $e');
      return false;
    }
  }

  Future<void> updateGroup(
      Group updatedGroup,
      UserManagement userManagement,
      NotificationManagement notificationManagement,
      Map<String, UserInviteStatus>? invitedUsers) async {
    try {
      final notificationFormat = NotificationFormats();
      NotificationUser editingNotification = notificationFormat
          .whenEditingGroup(updatedGroup, userManagement.currentUser!);

      // Retrieve the user's role using their ID from group.userRoles
      String? userRole =
          updatedGroup.userRoles[userManagement.currentUser!.userName];

      // Check if user has "Administration" or "Co-Administrator" roles
      if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
        // Check for duplicates before adding
        // if (!NotificationFormats.isDuplicateNotification(
        //     userManagement.currentUser!.notifications, editingNotification)) {
        //   userManagement.currentUser!.notifications.add(editingNotification);
        //   await userService.updateUser(userManagement.currentUser!);
        // }
        userManagement.currentUser!.notifications.add(editingNotification);
        await userService.updateUser(userManagement.currentUser!);
      }

      // Notify invited users about the update
      bool result = await _notifyUserInvitation(
          updatedGroup, notificationManagement, userManagement, invitedUsers);
      if (result) {
        devtools.log("Group updated = ${updatedGroup.toString()}");
      } else {
        devtools.log("Group couldn't be updated = ${updatedGroup.toString()}");
      }
    } catch (e) {
      print('Failed to update group: $e');
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
