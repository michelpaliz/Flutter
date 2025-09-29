import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:calendar_app_frontend/a-models/group_model/event/event_group_resolver.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/notification_model/userInvitation_status.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/group/error_classes/error_classes.dart';
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
  }) {
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

  /// Safer: fetch groups; optionally repair user.groupIds only for confirmed 404s.
  /// No UI flicker; emits once.
  Future<void> fetchAndInitializeGroups(
    List<String> groupIds, {
    bool repairUserGroupIds = false, // default: don't mutate user
  }) async {
    try {
      final uniqueIds = groupIds.toSet().toList();

      // Fetch in parallel with typed error handling
      final results = await Future.wait(uniqueIds.map((id) async {
        try {
          final g = await groupService.getGroupById(id);
          return (id: id, group: g, notFound: false);
        } catch (e) {
          final is404 = e is NotFoundException ||
              (e is HttpFailure && e.statusCode == 404);
          return (id: id, group: null as Group?, notFound: is404);
        }
      }), eagerError: false);

      final groups = <Group>[];
      final definitelyGone = <String>[]; // confirmed 404s only
      final unknownFailures = <String>[]; // timeouts/5xx/etc.

      for (final r in results) {
        if (r.group != null) {
          groups.add(r.group!);
        } else {
          if (r.notFound) {
            definitelyGone.add(r.id);
          } else {
            unknownFailures.add(r.id);
          }
        }
      }

      // Cache & emit once (no flicker)
      _lastFetchedGroups = groups;
      groupController.add(groups);

      // Only prune IDs when explicitly allowed AND we have confirmed 404s
      if (repairUserGroupIds && definitelyGone.isNotEmpty) {
        final newIds =
            uniqueIds.where((id) => !definitelyGone.contains(id)).toList();

        final changed = currentUser.groupIds.length != newIds.length ||
            !Set.of(currentUser.groupIds).containsAll(newIds);

        if (changed) {
          currentUser.groupIds = newIds;
          await userService.updateUser(currentUser);
        }
      }

      if (unknownFailures.isNotEmpty) {
        devtools.log('⚠️ Skipped pruning (unknown failures): $unknownFailures');
      }
    } catch (e) {
      devtools.log('❌ fetchAndInitializeGroups failed: $e');
      // Optional: keep previous list instead of nuking UI on global failure
      groupController.add(_lastFetchedGroups);
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

  // inside class GroupManagement extends ChangeNotifier
  void updateGroupPhoto({
    required String groupId,
    required String photoUrl,
    required String photoBlobName,
  }) {
    final idx = _lastFetchedGroups.indexWhere((g) => g.id == groupId);
    if (idx == -1) {
      devtools.log('⚠️ updateGroupPhoto: group not found: $groupId');
      return;
    }

    final updated = _lastFetchedGroups[idx].copyWith(
      photoUrl: photoUrl,
      photoBlobName: photoBlobName,
    );

    _lastFetchedGroups[idx] = updated;

    // keep currentGroup in sync if it's the one being edited
    if (_currentGroup?.id == groupId) {
      _currentGroup = updated;
    }

    // push to stream listeners and notify widgets
    groupController.add(List<Group>.from(_lastFetchedGroups));
    notifyListeners();
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
