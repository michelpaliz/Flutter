import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/node_services/group_services.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
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

  Future<void> fetchAndInitializeGroups(List<String> groupIds) async {
    try {
      List<Group> groups = [];
      List<String> validGroupIds = [];

      for (var id in groupIds) {
        try {
          final group = await groupService.getGroupById(id);
          groups.add(group);
          validGroupIds.add(id); // only add if group is valid
        } catch (e) {
          devtools.log('⚠️ Failed to fetch group by ID $id: $e');
        }
      }

      // ✅ Update the currentUser's group list in memory
      currentUser.groupIds = validGroupIds;

      // ✅ Update the user in the database to reflect valid groupIds only
      await userService.updateUser(currentUser); // <- THIS LINE

      groupController.add(groups);
    } catch (e) {
      devtools.log('❌ fetchAndInitializeGroups failed: $e');
      groupController.add([]);
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

  Future<bool> createGroup(
    Group group,
    NotificationManagement notificationManagement,
    UserManagement userManagement,
    Map<String, UserInviteStatus>? invitedUsers,
  ) async {
    try {
      // 1. Create group (returns full group with Mongo _id)
      Group createdGroup = await groupService.createGroup(group);
      devtools.log('✅ Group created: ${createdGroup.id}');

      // 2. Get the current user
      User user = await userService.getUserByUsername(currentUser.userName);

      if (createdGroup.id.isNotEmpty) {
        user.groupIds.add(createdGroup.id);
      }

      // 3. Create notification WITHOUT setting the ID manually
      final notificationFormat = NotificationFormats();
      NotificationUser adminNotification =
          notificationFormat.whenCreatingGroup(createdGroup, user);

      // 4. Save notification and get it back with generated Mongo _id
      final savedNotification =
          await notificationManagement.addNotificationToDB(
        adminNotification,
        userManagement,
      );

      // 5. Safely add the notification ID to the user if it was returned correctly
      if (savedNotification != null && savedNotification.id.isNotEmpty) {
        user.notifications.add(savedNotification.id);
      } else {
        devtools.log('⚠️ Failed to save notification for group creation');
      }

      // 6. Clean up any empty or invalid IDs to avoid backend issues
      user.notifications.removeWhere((id) => id.isEmpty);
      user.groupIds.removeWhere((id) => id.isEmpty);

      // 7. Save updated user to DB
      await userManagement.updateUser(user);

      // 8. Notify invited users
      bool result = await _notifyUserInvitation(
        createdGroup,
        notificationManagement,
        userManagement,
        invitedUsers,
      );

      // 9. If success, re-fetch groups
      if (result) {
        await fetchAndInitializeGroups(user.groupIds);
      } else {
        devtools.log(
            "❌ Group created, but failed to notify some users. User: ${user.userName}");
      }

      return true;
    } catch (e, stackTrace) {
      devtools.log('❌ Failed to add group: $e',
          error: e, stackTrace: stackTrace);
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
          .whenEditingGroup(updatedGroup, userManagement.user!);

      String? userRole = updatedGroup.userRoles[userManagement.user!.userName];

      if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
        userManagement.user!.notifications
            ?.add(editingNotification.id); // Use notification ID
        devtools
            .log("This is the user i want to update ${userManagement.user}");

        await userService.updateUser(userManagement.user!);
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
