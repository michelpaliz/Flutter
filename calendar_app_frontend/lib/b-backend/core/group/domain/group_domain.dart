import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event_group_resolver.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/group/error_classes/error_classes.dart';
import 'package:hexora/b-backend/core/group/repository/group_repository.dart';
import 'package:hexora/b-backend/login_user/user/api/user_api_client.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
// ✅ use repository instead of service
import 'package:hexora/b-backend/login_user/user/repository/user_repository.dart';

class GroupDomain extends ChangeNotifier {
  // Repos
  final GroupRepository groupRepository;
  final UserRepository userRepository;

  final GroupEventResolver groupEventResolver;

  // Streams
  StreamController<List<Group>>? _groupController;
  StreamController<List<Group>> get groupController =>
      _groupController ??= StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get groupStream => groupController.stream;

  // Current user & group
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

  bool _groupsInitialized = false;
  List<Group> _lastFetchedGroups = [];
  List<Group> get groups => _lastFetchedGroups;

  GroupDomain({
    required this.groupEventResolver,
    required User? user,
    GroupRepository? groupRepository,
    UserRepository? userRepository,
  })  : groupRepository = groupRepository ?? GroupRepository(),
        userRepository = userRepository ?? UserRepository(UserApiClient()) {
    _groupController = StreamController<List<Group>>.broadcast();
    if (user != null) setCurrentUser(user);
  }

  void setCurrentUser(User? user) {
    if (user == null) return;
    currentUser = user;
    if (!_groupsInitialized) {
      _initializeGroups(currentUser);
      _groupsInitialized = true;
    }
  }

  set currentGroup(Group? group) {
    _currentGroup = group;
    notifyListeners();
  }

  Future<void> _initializeGroups(User user) async {
    await fetchAndInitializeGroups(user.groupIds);
  }

  Future<void> fetchAndPopulateUsersAndRoles(String groupId) async {
    try {
      final meta = await groupRepository.getGroupMembersMeta(groupId);
      final roles = Map<String, String>.from(meta['userRoles'] ?? {});
      usersRolesStreamController.add(roles);
    } catch (e) {
      devtools.log('❌ fetchAndPopulateUsersAndRoles: $e');
    }
  }

  Future<void> fetchAndPopulateUsersInvitationStatus(String groupId) async {
    try {
      final meta = await groupRepository.getGroupMembersMeta(groupId);
      if (meta['invitedUsers'] != null) {
        final invitesMap =
            Map<String, dynamic>.from(meta['invitedUsers'] as Map);
        final invites = invitesMap.map(
          (k, v) => MapEntry(k, UserInviteStatus.fromJson(v)),
        );
        usersInvitationStatusStreamController.add(invites);
      }
    } catch (e) {
      devtools.log('❌ fetchAndPopulateUsersInvitationStatus: $e');
    }
  }

  Future<void> _refreshUserAndGroups(UserDomain userDomain) async {
    final freshUser = await userDomain.getUser();
    if (freshUser != null) {
      userDomain.setCurrentUser(freshUser);
      await fetchAndInitializeGroups(freshUser.groupIds);
    }
  }

  Future<void> fetchAndInitializeGroups(
    List<String> groupIds, {
    bool repairUserGroupIds = false,
  }) async {
    try {
      final uniqueIds = groupIds.toSet().toList();

      final results = await Future.wait(uniqueIds.map((id) async {
        try {
          final g = await groupRepository.getGroupById(id);
          return (id: id, group: g, notFound: false);
        } catch (e) {
          final is404 = e is NotFoundException ||
              (e is HttpFailure && e.statusCode == 404);
          return (id: id, group: null as Group?, notFound: is404);
        }
      }));

      final groups = <Group>[];
      final definitelyGone = <String>[];
      for (final r in results) {
        if (r.group != null) {
          groups.add(r.group!);
        } else if (r.notFound) {
          definitelyGone.add(r.id);
        }
      }

      _lastFetchedGroups = groups;
      groupController.add(groups);

      if (repairUserGroupIds && definitelyGone.isNotEmpty) {
        final newIds =
            uniqueIds.where((id) => !definitelyGone.contains(id)).toList();

        if (newIds.length != currentUser.groupIds.length) {
          currentUser.groupIds = newIds;
          // ✅ use repository (handles token)
          await userRepository.updateUser(currentUser);
        }
      }
    } catch (e) {
      devtools.log('❌ fetchAndInitializeGroups failed: $e');
      groupController.add(_lastFetchedGroups);
    }
  }

  Future<bool> createGroup(Group group, UserDomain userDomain) async {
    try {
      await groupRepository.createGroup(group);
      await _refreshUserAndGroups(userDomain);
      await fetchAndInitializeGroups(currentUser.groupIds);
      return true;
    } catch (e) {
      devtools.log('❌ Failed to create group: $e');
      return false;
    }
  }

  Future<Group> createGroupReturning(Group group, UserDomain userDomain) async {
    final created = await groupRepository.createGroup(group);

    // keep local cache coherent
    _lastFetchedGroups = [..._lastFetchedGroups, created];
    groupController.add(List<Group>.from(_lastFetchedGroups));
    if (!currentUser.groupIds.contains(created.id)) {
      currentUser.groupIds = [...currentUser.groupIds, created.id];
    }

    // optional: refresh from server
    await _refreshUserAndGroups(userDomain);
    await fetchAndInitializeGroups(currentUser.groupIds);

    notifyListeners();
    return created;
  }


  Future<bool> updateGroup(Group updatedGroup, UserDomain userDomain) async {
    try {
      await groupRepository.updateGroup(updatedGroup);
      await _refreshUserAndGroups(userDomain);
      await fetchAndInitializeGroups(currentUser.groupIds);
      return true;
    } catch (e) {
      devtools.log('❌ Failed to update group: $e');
      return false;
    }
  }

  Future<bool> removeGroup(Group group, UserDomain userDomain) async {
    try {
      await groupRepository.deleteGroup(group.id);
      await _refreshUserAndGroups(userDomain);
      await fetchAndInitializeGroups(currentUser.groupIds);
      return true;
    } catch (e) {
      devtools.log('❌ Failed to remove group: $e');
      return false;
    }
  }

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
    if (_currentGroup?.id == groupId) _currentGroup = updated;

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
