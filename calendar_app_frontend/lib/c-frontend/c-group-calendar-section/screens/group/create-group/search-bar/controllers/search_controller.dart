import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/login_user/user/repository/user_repository.dart';
import 'package:hexora/f-themes/themes/theme_colors.dart';

class GroupSearchController extends ChangeNotifier {
  final User? currentUser;
  final Group? group;
  final UserRepository _userRepo;

  GroupSearchController({
    required this.currentUser,
    required this.group,
    required UserRepository userRepository,
  }) : _userRepo = userRepository {
    if (currentUser != null) {
      usersInGroup = [currentUser!]; // creator by default
      userRoles[currentUser!.id] = 'owner'; // 🔑 key by userId, role lowercase
    }

    if (group != null) {
      _loadGroupUsers();
      _loadInvitedUsers();
    }
  }

  // Local state
  List<User> usersInGroup = [];

  /// 🔑 role map: userId -> role (lowercase: 'owner' | 'co-admin' | 'member')
  Map<String, String> userRoles = {};

  /// We keep results as simple usernames for the search UI
  List<String> searchResults = [];

  // ---------- Loaders ----------
  Future<void> _loadGroupUsers() async {
    if (group == null) return;
    try {
      for (final id in group!.userIds) {
        final u = await _userRepo.getUserById(id);
        if (!usersInGroup.any((x) => x.id == u.id)) {
          usersInGroup.add(u);
        }
      }
      notifyListeners();
    } catch (_) {
      // swallow; UI can still function with partial data
    }
  }

  void _loadInvitedUsers() {
    if (group?.invitedUsers == null) return;

    // invitedUsers is Map<String /*userId*/, UserInviteStatus>
    group!.invitedUsers!.forEach((userId, status) {
      if (status.invitationAnswer == true ||
          (status.informationStatus).toLowerCase() == 'accepted') {
        userRoles[userId] = (status.role).toLowerCase(); // normalize
      }
    });
  }

  // ---------- Search / Add / Remove ----------
  Future<void> searchUser(String query, BuildContext context) async {
    final q = query.trim();
    if (q.length < 3) {
      clearResults();
      return;
    }
    try {
      final results = await _userRepo.searchUsernames(q.toLowerCase());
      // Filter out already-added usernames
      final existingUsernames = usersInGroup.map((u) => u.userName).toSet();
      searchResults =
          results.where((name) => !existingUsernames.contains(name)).toList();
      notifyListeners();
    } catch (e) {
      searchResults = [];
      notifyListeners();
      _showSnackBar(context, 'Error searching user');
    }
  }

  Future<User?> addUser(String username, BuildContext context) async {
    try {
      final user = await _userRepo.getUserByUsername(username);

      // prevent duplicates by id or username
      if (usersInGroup.any((u) => u.id == user.id || u.userName == username)) {
        return null;
      }

      usersInGroup.add(user);
      // default role for new users
      userRoles[user.id] = 'member'; // 🔑 keyed by userId
      // remove from results
      searchResults.remove(username);

      notifyListeners();
      return user;
    } catch (e) {
      _showSnackBar(context, 'Error adding user');
      return null;
    }
  }

  void removeUser(String username) {
    final removed = usersInGroup.firstWhere(
      (u) => u.userName == username,
      orElse: () => User.empty(),
    );
    // If found, remove and clear role by id
    if (removed.id.isNotEmpty) {
      usersInGroup.removeWhere((u) => u.id == removed.id);
      userRoles.remove(removed.id);
    } else {
      // fallback by username-only removal (shouldn’t normally happen)
      usersInGroup.removeWhere((u) => u.userName == username);
      userRoles.remove(username); // legacy safety
    }
    notifyListeners();
  }

  void changeRole(String username, String newRole) {
    // find that user's id
    final u = usersInGroup.firstWhere(
      (x) => x.userName == username,
      orElse: () => User.empty(),
    );
    if (u.id.isNotEmpty) {
      userRoles[u.id] = newRole.toLowerCase();
    } else {
      // legacy fallback if only username is known
      userRoles[username] = newRole.toLowerCase();
    }
    notifyListeners();
  }

  void clearResults() {
    if (searchResults.isEmpty) return;
    searchResults.clear();
    notifyListeners();
  }

  // ---------- UI helper ----------
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ThemeColors.getContainerBackgroundColor(context),
        content: Text(
          message,
          style: TextStyle(
            color: ThemeColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
