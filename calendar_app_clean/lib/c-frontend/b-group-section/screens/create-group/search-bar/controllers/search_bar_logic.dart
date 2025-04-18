import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';

import "package:flutter_gen/gen_l10n/app_localizations.dart";

mixin SearchBarLogic<T extends StatefulWidget> on State<T> {
  List<String> searchResults = [];
  Map<String, String> userRoles = {};
  List<User> usersInGroup = [];
  Map<String, UserInviteStatus>? invitedUsers;

  late UserService userService;
  User? currentUser;
  Group? group;
  late UserManagement userManagement;
  late Function(List<User>, Map<String, String>) notifyParent;

  void initLogic(
    BuildContext context,
    User? user,
    Group? groupPassed,
    Function(List<User>, Map<String, String>) onChange,
  ) {
    userService = UserService();
    currentUser = user;
    group = groupPassed;
    notifyParent = onChange;

    if (currentUser != null) {
      userRoles[currentUser!.userName] = 'Administrator';
      usersInGroup.add(currentUser!);
    }

    invitedUsers = group?.invitedUsers;
  }

  void searchUser(String username) async {
    try {
      final response = await userService.searchUsers(username.toLowerCase());

      if (!mounted) return;

      if (response is List<String>) {
        final filtered = response.where((name) {
          return !usersInGroup.any((u) => u.userName == name) &&
              !userRoles.containsKey(name);
        }).toList();

        setState(() {
          searchResults = filtered;
        });
      } else {
        clearSearchResults();
        _showSnackBar(context, 'User not found');
      }
    } catch (e) {
      print('Error searching user: $e');
      clearSearchResults();
    }
  }

  void clearSearchResults() {
    setState(() => searchResults = []);
  }

  void addUser(String username) async {
    try {
      final user = await userService.getUserByUsername(username);
      if (!mounted || userRoles.containsKey(user.userName)) return;

      setState(() {
        userRoles[user.userName] = 'Member';
        usersInGroup.add(user);
      });

      notifyParent(usersInGroup, userRoles);
      _showSnackBar(context, 'User added: ${user.userName}');
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  void removeUser(String username) {
    if (username == currentUser?.userName) {
      _showSnackBar(context, AppLocalizations.of(context)!.cannotRemoveYourself);
      return;
    }

    setState(() {
      usersInGroup.removeWhere((u) => u.userName == username);
      userRoles.remove(username);
    });

    notifyParent(usersInGroup, userRoles);
  }

  void changeUserRole(String username, String newRole) {
    setState(() {
      userRoles[username] = newRole;
    });
    notifyParent(usersInGroup, userRoles);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
