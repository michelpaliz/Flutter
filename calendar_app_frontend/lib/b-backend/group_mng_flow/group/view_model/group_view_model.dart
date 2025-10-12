import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
import 'package:hexora/b-backend/group_mng_flow/invite/repository/invite_repository.dart';
import 'package:hexora/b-backend/auth_user/auth/auth_database/auth_provider.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
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
  late InvitationRepository invitationRepository; // NEW

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
    required InvitationRepository invitationRepository, // NEW
    required BuildContext context,
  }) {
    this.context = context;
    this.userDomain = userDomain;
    this.groupDomain = groupDomain;
    this.notificationDomain = notificationDomain;
    this.invitationRepository = invitationRepository; // NEW
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
    membersById.remove(userId);
    notifyListeners();
  }

  void onRolesUpdated(Map<String, String> updatedRoles) {
    userRoles = updatedRoles;
    notifyListeners();
  }

  void hydrateMembers(List<User> users) {
    for (final u in users) {
      membersById[u.id] = u;
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
      if (me == null || me.id.isEmpty) {
        throw StateError('Current user not loaded');
      }

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
        defaultCalendarId: null,
        defaultCalendar: null,
      );

      // ✅ Create group and get its id
      final created =
          await groupDomain.createGroupReturning(newGroup, userDomain);

      // ✅ Send invitations (exclude the owner)
      await _sendInvitationsForGroup(created.id);

      // ✅ Handle photo (optional)
      if (selectedImage == null) {
        // Ensure the stream is up-to-date anyway
        await groupDomain.refreshGroupsForCurrentUser(userDomain);
        return true;
      }

      final token = context!.read<AuthProvider>().lastToken;
      if (token == null) throw Exception('Not authenticated');

      await groupDomain.groupRepository.uploadAndCommitGroupPhoto(
        groupId: created.id,
        file: File(selectedImage!.path),
      );

      // 🔄 Pull the latest server state so repo emits updated photo urls
      await groupDomain.refreshGroupsForCurrentUser(userDomain);

      return true;
    } catch (e) {
      devtools.log("❌ Error creating group: $e");
      return false;
    }
  }

  // ✅ Invites via Invitations API
  Future<void> _sendInvitationsForGroup(String groupId) async {
    final token = context!.read<AuthProvider>().lastToken;
    if (token == null) throw Exception('Not authenticated');

    for (final user in usersInGroup) {
      if (user.id == currentUser!.id) continue; // skip owner
      final role = userRoles[user.id] ?? 'member';

      final res = await invitationRepository.create(
        groupId: groupId,
        userId: user.id, // invite by userId (or use email: user.email)
        role: role,
        token: token,
      );

      if (res is RepoFailure) {
        devtools.log(
            '❌ Failed to invite ${user.userName} ($role): ${res.runtimeType}');
      }
    }
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
}
