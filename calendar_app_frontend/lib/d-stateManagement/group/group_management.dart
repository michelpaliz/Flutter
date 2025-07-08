import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:calendar_app_frontend/a-models/group_model/event/event_group_resolver.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/notification_model/userInvitation_status.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/group/group_services.dart';
import 'package:calendar_app_frontend/b-backend/api/user/user_services.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';

class GroupManagement extends ChangeNotifier {
  final GroupService groupService = GroupService();
  final UserService userService = UserService();
  final GroupEventResolver groupEventResolver;

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

  // GroupManagement({required User? user}) {
  //   _groupController =
  //       StreamController<List<Group>>.broadcast(); // Initialize here
  //   if (user != null) {
  //     setCurrentUser(user);
  //   }
  // }
  
  GroupManagement({
    required this.groupEventResolver,
    required User? user,
  }){
    _groupController = StreamController<List<Group>>.broadcast();
    if (user != null) setCurrentUser(user);
  }

  List<Group> get groups => _lastFetchedGroups;
  List<Group> _lastFetchedGroups = [];

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

  Future<void> fetchAndPopulateUsersAndRoles(String groupId) async {
    await fetchAndPopulateData(groupId, fetchRoles, usersRolesStreamController);
  }

  Future<void> fetchAndPopulateUsersInvitationStatus(String groupId) async {
    await fetchAndPopulateData(
      groupId,
      fetchStatus,
      usersInvitationStatusStreamController,
    );
  }

  Future<Map<String, String>> fetchRoles(String groupId) async {
    Group groupFetched = await groupService.getGroupById(groupId);
    return groupFetched.userRoles;
  }

  Future<Map<String, UserInviteStatus>?> fetchStatus(String groupId) async {
    Group groupFetched = await groupService.getGroupById(groupId);
    return groupFetched.invitedUsers;
  }

  Future<void> _refreshUserAndGroups(UserManagement userManagement) async {
    final freshUser = await userManagement.getUser();
    if (freshUser != null) {
      userManagement.setCurrentUser(freshUser);
      await fetchAndInitializeGroups(freshUser.groupIds);
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
      devtools.log(
        'Failed to fetch and populate data: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
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

      // ✅ Save to internal state before pushing to the stream
      _lastFetchedGroups = groups;

      // ✅ Clear previous group data
      groupController.add([]);

      // ✅ Update the currentUser's group list in memory
      currentUser.groupIds = validGroupIds;

      // ✅ Update the user in the database to reflect valid groupIds only
      await userService.updateUser(currentUser);

      // ✅ Now add fresh data
      groupController.add(groups);
    } catch (e) {
      devtools.log('❌ fetchAndInitializeGroups failed: $e');
      groupController.add([]);
    }
  }

  Future<bool> createGroup(Group group, UserManagement userManagement) async {
    try {
      // 1. Create group (returns full group with Mongo _id)
      Group createdGroup = await groupService.createGroup(group);
      devtools.log('✅ Group created: ${createdGroup.id}');

      // 2. Refresh current user to get updated notifications and group IDs
      await _refreshUserAndGroups(userManagement);

      // 3. Re-fetch groups
      await fetchAndInitializeGroups(currentUser.groupIds);

      return true;
    } catch (e, stackTrace) {
      devtools.log(
        '❌ Failed to add group: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> updateGroup(
    Group updatedGroup,
    UserManagement userManagement,
  ) async {
    try {
      // 1. Call backend to update the group
      await groupService.updateGroup(updatedGroup);

      // 2. Refresh current user to get updated notifications and group info
      await _refreshUserAndGroups(userManagement);

      // 3. Re-fetch groups to update local state
      await fetchAndInitializeGroups(currentUser.groupIds);

      return true;
    } catch (e, stackTrace) {
      devtools.log(
        '❌ Failed to update group: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> removeGroup(Group group, UserManagement userManagement) async {
    try {
      // 1. Delete group from backend
      await groupService.deleteGroup(group.id);

      // 2. Refresh current user
      await _refreshUserAndGroups(userManagement);

      // 3. Re-fetch groups
      await fetchAndInitializeGroups(currentUser.groupIds);

      return true;
    } catch (e, stackTrace) {
      devtools.log(
        '❌ Failed to remove group: $e',
        error: e,
        stackTrace: stackTrace,
      );
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
