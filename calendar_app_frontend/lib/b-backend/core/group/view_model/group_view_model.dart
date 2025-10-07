import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/auth_provider.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/notification/domain/notification_domain.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class GroupViewModel extends ChangeNotifier {
  BuildContext? context;

  late NotificationDomain notificationDomain;
  late UserDomain userDomain;
  late GroupDomain groupDomain;

  User? currentUser;
  final Map<String, User> membersById = {}; // cache for UI

  // UI fields
  String groupName = '';
  String groupDescription = '';
  XFile? selectedImage;

  List<User> usersInGroup = [];
  Map<String, String> userRoles = {}; // userId -> role

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  GroupViewModel();

  /// Merge temporary selection from the search bar into the controller's UI state.
  /// Accepts roles keyed by either userId or userName and normalizes to userId.
  void onDataChanged(List<User> newUsers, Map<String, String> newRoles) {
    // 1) Merge users into the local UI list + cache
    for (final user in newUsers) {
      if (!usersInGroup.any((u) => u.id == user.id)) {
        usersInGroup.add(user);
      }
      // NOTE: if you later standardize on id keys, change this to: membersById[user.id] = user;
      membersById[user.id] = user;
    }

    // 2) Normalize roles to userId keys (supports username or userId inputs)
    final Map<String, String> normalized = {};
    for (final entry in newRoles.entries) {
      final key = entry.key;
      final role = entry.value;

      // If key is already a userId
      final byIdIdx = usersInGroup.indexWhere((u) => u.id == key);
      if (byIdIdx != -1) {
        normalized[key] = role;
        continue;
      }

      // Else try treat key as userName
      final byNameIdx = usersInGroup.indexWhere((u) => u.userName == key);
      if (byNameIdx != -1) {
        normalized[usersInGroup[byNameIdx].id] = role;
      }
    }

    // 3) Apply roles (by userId)
    userRoles.addAll(normalized);

    notifyListeners();
  }

  /// 🧩 Initialization (called by UI)
  void initialize({
    required User user,
    required UserDomain userDomain,
    required GroupDomain groupDomain,
    required NotificationDomain notificationDomain,
    required BuildContext context,
  }) {
    this.context = context;
    this.userDomain = userDomain;
    this.groupDomain = groupDomain;
    this.notificationDomain = notificationDomain;
    this.currentUser = user;

    // default group data
    usersInGroup = [user];
    userRoles = {user.id: 'owner'};
    membersById[user.id] = user;

    groupDomain.setCurrentUser(user);
  }

  // ✅ UI helpers
  void addMember(User newUser) {
    if (!usersInGroup.any((u) => u.id == newUser.id)) {
      usersInGroup.add(newUser);
      userRoles[newUser.id] ??= 'member';
      membersById[newUser.id] = newUser;
      notifyListeners();
    }
  }

  void removeUser(String userId) {
    if (userId == currentUser?.id) {
      _showSnackBar(AppLocalizations.of(context!)!.cannotRemoveYourself);
      return;
    }
    usersInGroup.removeWhere((u) => u.id == userId);
    userRoles.remove(userId);
    membersById.remove(userId); // ✅ direct remove by id
    notifyListeners();
  }

  void onRolesUpdated(Map<String, String> updatedRoles) {
    userRoles = updatedRoles;
    notifyListeners();
  }

  void hydrateMembers(List<User> users) {
    for (final u in users) {
      membersById[u.id] = u; // ✅ was u.userName
      userRoles[u.id] = userRoles[u.id] ?? 'member';
      if (!usersInGroup.any((x) => x.id == u.id)) {
        usersInGroup.add(u);
      }
    }
    notifyListeners();
  }

  // ✅ UI: pick image
  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) selectedImage = image;
    notifyListeners();
  }

  // ✅ Helpers
  void _showSnackBar(String message) {
    if (context != null) {
      ScaffoldMessenger.of(context!)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  bool hasAtLeastOneUser() => userRoles.isNotEmpty;

  // ✅ UI → Create group flow
  Future<void> submitGroupFromUI() async {
    groupName = nameController.text.trim();
    groupDescription = descriptionController.text.trim();

    if (groupName.isEmpty || groupDescription.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context!)!.requiredTextFields);
      return;
    }

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final ok = await _createGroupAndMaybeUploadPhoto();

    if (context!.mounted) {
      Navigator.of(context!).pop();
      if (ok) {
        _showSnackBar(AppLocalizations.of(context!)!.groupCreated);
        Navigator.of(context!).pop();
      } else {
        _showSnackBar(AppLocalizations.of(context!)!.failedToCreateGroup);
      }
    }
  }


  Future<bool> _createGroupAndMaybeUploadPhoto() async {
    try {
      final me = currentUser;
      if (me == null || me.id.isEmpty)
        throw StateError('Current user not loaded');

      final newGroup = Group(
        id: '',
        name: groupName,
        ownerId: me.id,
        userRoles: {me.id: 'owner'},
        userIds: [me.id],
        createdTime: DateTime.now(),
        description: groupDescription,
        photoUrl: '',
        photoBlobName: null,
        invitedUsers: _buildInvites(),
        defaultCalendarId: null,
        defaultCalendar: null,
      );

      // ✅ get the created group (and its id)
      final created =
          await groupDomain.createGroupReturning(newGroup, userDomain);

      if (selectedImage == null) return true;

      final token = context!.read<AuthProvider>().lastToken;
      if (token == null) throw Exception('Not authenticated');

      await groupDomain.groupRepository.uploadAndCommitGroupPhoto(
        groupId: created.id, // <-- use created.id
        file: File(selectedImage!.path),
      );

      // If your upload endpoint returns updated urls, refresh cache here.
      groupDomain.updateGroupPhoto(
        groupId: created.id,
        photoUrl: created.photoUrl ?? '',
        photoBlobName: created.photoBlobName ?? '',
      );

      return true;
    } catch (e) {
      devtools.log("❌ Error creating group: $e");
      return false;
    }
  }

  // ✅ Invites builder
  Map<String, UserInviteStatus> _buildInvites() {
    final Map<String, UserInviteStatus> invites = {};
    for (final user in usersInGroup) {
      if (user.id == currentUser!.id) continue;
      invites[user.id] = UserInviteStatus(
        id: user.id,
        invitationAnswer: null,
        role: userRoles[user.id] ?? 'member',
        sendingDate: DateTime.now(),
        informationStatus: 'Pending',
        attempts: 1,
        status: 'Unresolved',
      );
    }
    return invites;
  }

  // ✅ Search users (delegated to backend endpoint)
  Future<List<User>> searchUsers(String query, {int limit = 20}) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    try {
      final token = context?.read<AuthProvider>().lastToken;
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/users/search?q=${Uri.encodeQueryComponent(q)}&limit=$limit',
      );
      final resp = await http.get(uri, headers: {
        if (token != null) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is List) {
          return decoded.map<User>((e) => User.fromJson(e)).toList();
        }
        if (decoded is Map && decoded['items'] is List) {
          final items = decoded['items'] as List;
          return items.map<User>((e) => User.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      devtools.log('searchUsers error: $e');
      return [];
    }
  }

  // ✅ Load members via management layer
  Future<void> loadGroupMembers(String groupId) async {
    try {
      final meta =
          await groupDomain.groupRepository.getGroupMembersMeta(groupId);
      final roles = Map<String, String>.from(meta['userRoles'] ?? {});
      userRoles = roles;

      final ids = roles.keys.toList();
      final profiles = await groupDomain.groupRepository.getGroupMemberProfiles(
        groupId,
        ids: ids,
      );

      membersById.clear();
      for (final user in profiles) {
        membersById[user.id] = user;
      }

      usersInGroup = membersById.values.toList();
      notifyListeners();
    } catch (e) {
      devtools.log('❌ loadGroupMembers error: $e');
      _showSnackBar('Failed to load group members.');
    }
  }

  // ✅ Utility roles
  final List<String> assignableRoles = const ['member', 'co-admin'];

  bool canEditRole(String userId) =>
      currentUser?.id != userId && (userRoles[userId] != 'owner');

  void setRole(String userId, String newRole) {
    if (!userRoles.containsKey(userId)) return;
    if (!canEditRole(userId)) return;
    if (userRoles[userId] == newRole) return;
    userRoles[userId] = newRole;
    notifyListeners();
  }

  static Future<List<Group>> fetchGroups(
    User? user,
    GroupDomain groupManager,
  ) async {
    if (user == null) {
      devtools.log('⚠️ fetchGroups: user is null.');
      return const [];
    }

    try {
      await groupManager.fetchAndInitializeGroups(user.groupIds);
      return List<Group>.from(groupManager.groups);
    } catch (e) {
      devtools.log('❌ fetchGroups error: $e');
      return const [];
    }
  }
}
