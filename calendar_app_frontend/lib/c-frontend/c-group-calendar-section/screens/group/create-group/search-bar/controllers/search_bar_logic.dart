import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/auth_user/user/repository/user_repository.dart';
import 'package:hexora/l10n/app_localizations.dart';

mixin SearchBarLogic<T extends StatefulWidget> on State<T> {
  // UI state
  List<String> searchResults = [];

  /// 🔑 role map: userId -> role (lowercase)
  Map<String, String> userRoles = {};

  List<User> usersInGroup = [];

  // Deps
  late UserRepository userRepository;
  late UserDomain userDomain;

  User? currentUser;
  Group? group;

  /// Notify parent with latest local state
  late void Function(List<User>, Map<String, String>) notifyParent;

  /// Call this from initState of the widget using the mixin.
  void initLogic({
    required BuildContext context,
    required User? user,
    required Group? groupPassed,
    required UserRepository repo,
    required UserDomain userDomain,
    required void Function(List<User>, Map<String, String>) onChange,
  }) {
    userRepository = repo;
    userDomain = userDomain;
    currentUser = user;
    group = groupPassed;
    notifyParent = onChange;

    // Seed current user as owner (creator)
    if (currentUser != null) {
      usersInGroup.add(currentUser!);
      userRoles[currentUser!.id] = 'owner'; // 🔑 key by userId; role lowercase
    }
  }

  // -------- Search ----------
  Future<void> searchUser(String username) async {
    final q = username.trim().toLowerCase();
    if (q.length < 3) {
      clearSearchResults();
      return;
    }

    try {
      final results = await userRepository.searchUsernames(q);
      if (!mounted) return;

      final existingUsernames = usersInGroup.map((u) => u.userName).toSet();
      final filtered =
          results.where((name) => !existingUsernames.contains(name)).toList();

      setState(() {
        searchResults = filtered;
      });
    } catch (e) {
      clearSearchResults();
      _showSnackBar(context, 'Error searching user');
    }
  }

  void clearSearchResults() {
    if (!mounted) return;
    setState(() => searchResults = []);
  }

  // -------- Add / Remove / Role ----------
  Future<void> addUser(String username) async {
    try {
      final user = await userRepository.getUserBySelector(username);
      if (!mounted) return;

      // Don’t add duplicates
      if (usersInGroup
          .any((u) => u.id == user.id || u.userName == user.userName)) {
        return;
      }

      setState(() {
        usersInGroup.add(user);
        userRoles[user.id] = 'member'; // default role, lowercase
        searchResults.remove(username);
      });

      notifyParent(usersInGroup, userRoles);
      _showSnackBar(context, 'User added: ${user.userName}');
    } catch (e) {
      _showSnackBar(context, 'Error adding user');
    }
  }

  void removeUser(String username) {
    final me = currentUser;

    if (me != null && username == me.userName) {
      _showSnackBar(
        context,
        AppLocalizations.of(context)!.cannotRemoveYourself,
      );
      return;
    }

    // find user to remove by username so we can delete its role by userId
    final toRemove = usersInGroup.firstWhere(
      (u) => u.userName == username,
      orElse: () => User.empty(),
    );

    setState(() {
      usersInGroup.removeWhere((u) => u.userName == username);
      if (toRemove.id.isNotEmpty) {
        userRoles.remove(toRemove.id);
      } else {
        // legacy fallback (shouldn't normally be needed)
        userRoles.remove(username);
      }
    });

    notifyParent(usersInGroup, userRoles);
  }

  void changeUserRole(String username, String newRole) {
    // map username -> userId
    final u = usersInGroup.firstWhere(
      (x) => x.userName == username,
      orElse: () => User.empty(),
    );

    if (!mounted) return;

    setState(() {
      if (u.id.isNotEmpty) {
        userRoles[u.id] = newRole.toLowerCase();
      } else {
        // fallback if somehow id is unavailable
        userRoles[username] = newRole.toLowerCase();
      }
    });

    notifyParent(usersInGroup, userRoles);
  }

  // -------- UI helper ----------
  void _showSnackBar(BuildContext context, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
