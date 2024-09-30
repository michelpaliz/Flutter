import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/group.dart';
import 'package:first_project/a-models/notification_user.dart';
import 'package:first_project/a-models/user.dart';
import 'package:first_project/a-models/userInvitationStatus.dart';
import 'package:first_project/b-backend/database_conection/node_services/group_services.dart';
import 'package:first_project/b-backend/database_conection/node_services/user_services.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/utilities/notification_formats.dart';
import 'package:flutter/material.dart';

class GroupManagement extends ChangeNotifier {
  final GroupService groupService = GroupService();
  final UserService userService = UserService();

  StreamController<List<Group>>? _groupController;
  StreamController<List<Group>> get groupController =>
      _groupController ??= StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get groupStream => groupController.stream;

  late User currentUser;
  Group? _currentGroup;
  Group? get currentGroup => _currentGroup;

  // Stream controllers for managing user lists
  StreamController<List<User>>? _usersInGroupStreamController;
  StreamController<List<User>> get usersInGroupStreamController =>
      _usersInGroupStreamController ??=
          StreamController<List<User>>.broadcast();
  Stream<List<User>> get usersInGroupStream =>
      usersInGroupStreamController.stream;

  StreamController<Map<String, String>>? _usersRolesStreamController;
  StreamController<Map<String, String>> get usersRolesStreamController =>
      _usersRolesStreamController ??=
          StreamController<Map<String, String>>.broadcast();
  Stream<Map<String, String>> get userRolesStream =>
      usersRolesStreamController.stream;

  StreamController<Map<String, UserInviteStatus>?>?
      _usersInvitationStatusStreamController;
  StreamController<Map<String, UserInviteStatus>?>
      get usersInvitationStatusStreamController =>
          _usersInvitationStatusStreamController ??=
              StreamController<Map<String, UserInviteStatus>?>.broadcast();
  Stream<Map<String, UserInviteStatus>?> get usersInvitationStatusStream =>
      usersInvitationStatusStreamController.stream;

  bool _groupsInitialized = false; // Flag for initialization

  GroupManagement({required User? user}) {
    _groupController =
        StreamController<List<Group>>.broadcast(); // Initialize here
    if (user != null) {
      setCurrentUser(user);
    }
  }

  void setCurrentUser(User? user) {
    if (user == null) return; // Avoid null user
    currentUser = user;
    if (!_groupsInitialized) {
      _initializeGroups(currentUser);
      _groupsInitialized = true; // Set flag after initialization
    }
  }

  set currentGroup(Group? group) {
    _currentGroup = group;
    notifyListeners(); // Notify listeners when currentGroup changes
  }

  Future<void> _initializeGroups(User user) async {
    await fetchAndInitializeGroups(user.groupIds);
  }

  // Future<void> fetchAndInitializeGroups(List<String> groupIds) async {
  //   try {
  //     // Immediately emit an empty list to indicate the stream is empty
  //     groupController.add([]);

  //     if (groupIds.isNotEmpty) {
  //       List<Future<Group>> groupFutures =
  //           groupIds.map((id) => groupService.getGroupById(id)).toList();
  //       List<Group> groups = await Future.wait(groupFutures);

  //       // Once data is fetched, emit the fetched list to the stream
  //       groupController.add(groups);
  //       devtools
  //           .log('Fetched and populated groups: ${groups.length} groups added');
  //     } else {
  //       // If no groupIds, emit an empty list (already done above but keeping it for clarity)
  //       groupController.add([]);
  //       devtools
  //           .log('No groupIds provided, emitting an empty list to the stream');
  //     }
  //   } catch (e, stackTrace) {
  //     devtools.log('Failed to fetch and populate groups: $e',
  //         error: e, stackTrace: stackTrace);
  //     // Optionally emit an error state or empty list in case of failure
  //     groupController.add([]); // To clear previous data on error
  //   }
  // }

  Future<void> fetchAndInitializeGroups(List<String> groupIds) async {
    try {
      // Ensure that listeners are attached before emitting an empty list
      await Future.delayed(Duration(milliseconds: 100));
      groupController.add([]); // Emit empty list first

      if (groupIds.isNotEmpty) {
        List<Future<Group>> groupFutures =
            groupIds.map((id) => groupService.getGroupById(id)).toList();
        List<Group> groups = await Future.wait(groupFutures);

        groupController.add(groups); // Emit fetched groups
      } else {
        groupController.add([]); // Emit empty list if no groups
      }
    } catch (e, stackTrace) {
      groupController.add([]); // Emit empty list on error
    }
  }

  Future<void> fetchAndPopulateData<T>(
    String groupId,
    Future<T> Function(String) fetchData,
    StreamController<T> controller,
  ) async {
    try {
      T data = await fetchData(groupId);
      controller.add(data);
    } catch (e, stackTrace) {
      devtools.log('Failed to fetch and populate data: $e',
          error: e, stackTrace: stackTrace);
    }
  }

  Future<void> fetchAndPopulateUsersAndRoles(String groupId) async {
    await fetchAndPopulateData(groupId, fetchRoles, usersRolesStreamController);
  }

  Future<void> fetchAndPopulateUsersInvitationStatus(String groupId) async {
    await fetchAndPopulateData(
        groupId, fetchStatus, usersInvitationStatusStreamController);
  }

  Future<Map<String, String>> fetchRoles(String groupId) async {
    Group groupFetched = await groupService.getGroupById(groupId);
    return groupFetched.userRoles;
  }

  Future<Map<String, UserInviteStatus>?> fetchStatus(String groupId) async {
    Group groupFetched = await groupService.getGroupById(groupId);
    return groupFetched.invitedUsers;
  }

  Future<bool> addGroup(
      Group group,
      NotificationManagement notificationManagement,
      UserManagement userManagement,
      Map<String, UserInviteStatus>? invitedUsers) async {
    try {
      bool groupCreated = await groupService.createGroup(group);

      if (!groupCreated) {
        devtools.log('Failed to create group in group service');
        return false;
      }

      User user = await userService.getUserByUsername(currentUser.userName);
      user.groupIds.add(group.id);

      NotificationFormats notificationFormat = NotificationFormats();
      NotificationUser adminNotification =
          notificationFormat.whenCreatingGroup(group, user);

      user.notifications.add(adminNotification);
      user.hasNewNotifications = true;

      await notificationManagement.addNotificationToDB(
          adminNotification, userManagement);

      bool result = await _notifyUserInvitation(
          group, notificationManagement, userManagement, invitedUsers);

      if (result) {
        userManagement.updateUser(user);
        fetchAndInitializeGroups(
            user.groupIds); // Re-fetch groups instead of updating locally
      } else {
        devtools.log("Group couldn't be added = ${user.toString()}");
      }

      return true;
    } catch (e, stackTrace) {
      devtools.log('Failed to add group: $e', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> _notifyUserInvitation(
      Group group,
      NotificationManagement notificationManagement,
      UserManagement userManagement,
      Map<String, UserInviteStatus>? invitedUsers) async {
    final notificationFormat = NotificationFormats();

    final currentInvitedUserNames = group.invitedUsers?.keys.toSet() ?? {};
    final newInviteeUserNames = invitedUsers?.keys.toSet() ?? {};

    final usersToNotify =
        currentInvitedUserNames.difference(newInviteeUserNames);

    try {
      if (usersToNotify.isNotEmpty) {
        final notificationResults =
            await Future.wait(usersToNotify.map((userName) async {
          final invitedUser = await userService.getUserByUsername(userName);
          NotificationUser invitationNotification =
              notificationFormat.createGroupInvitation(group, invitedUser);

          return notificationManagement.addNotificationToDB(
              invitationNotification, userManagement);
        }));

        if (notificationResults.contains(false)) {
          devtools.log('Failed to add some notifications');
          return false;
        }
      }

      await groupService.updateGroup(group);
      fetchAndInitializeGroups(currentUser.groupIds); // Refresh group data

      return true;
    } catch (e, stackTrace) {
      devtools.log('Failed to notify users for invitation: $e',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> updateGroup(
      Group updatedGroup,
      UserManagement userManagement,
      NotificationManagement notificationManagement,
      Map<String, UserInviteStatus>? invitedUsers) async {
    try {
      groupService.updateGroup(updatedGroup);
      final notificationFormat = NotificationFormats();
      NotificationUser editingNotification = notificationFormat
          .whenEditingGroup(updatedGroup, userManagement.currentUser!);

      String? userRole =
          updatedGroup.userRoles[userManagement.currentUser!.userName];

      if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
        userManagement.currentUser!.notifications.add(editingNotification);
        await userService.updateUser(userManagement.currentUser!);
      }

      bool result = await _notifyUserInvitation(
          updatedGroup, notificationManagement, userManagement, invitedUsers);
      if (result) {
        fetchAndInitializeGroups(currentUser.groupIds); // Re-fetch groups
        return true; // Indicate success
      } else {
        devtools.log("Group couldn't be updated = ${updatedGroup.toString()}");
        return false; // Indicate failure
      }
    } catch (e, stackTrace) {
      devtools.log('Failed to update group: $e',
          error: e, stackTrace: stackTrace);
      return false; // Indicate failure due to exception
    }
  }

  Future<bool> removeGroup(Group group, UserManagement userManagement) async {
    try {
      await groupService.deleteGroup(group.id);

      // Update the user's group list
      User updatedUser =
          await userService.getUserByUsername(currentUser.userName);
      updatedUser.groupIds.remove(group.id);

      // Update the UserManagement state
      userManagement.setCurrentUser(updatedUser);

      // Re-fetch groups to ensure the local state is updated
      await fetchAndInitializeGroups(updatedUser.groupIds);

      return true;
    } catch (e, stackTrace) {
      devtools.log('Failed to remove group: $e',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  @override
  void dispose() {
    _groupController?.close();
    _usersInGroupStreamController?.close();
    _usersRolesStreamController?.close();
    _usersInvitationStatusStreamController?.close();
    super.dispose();
  }
}
