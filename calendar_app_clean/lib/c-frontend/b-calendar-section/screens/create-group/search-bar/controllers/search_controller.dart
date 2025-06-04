import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/api/user/user_services.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class GroupSearchController extends ChangeNotifier {
  final User? currentUser;
  final Group? group;

  final UserService _userService = UserService();

  List<User> usersInGroup = [];
  Map<String, String> userRoles = {};
  List<String> searchResults = [];

  GroupSearchController({
    required this.currentUser,
    required this.group,
  }) {
    if (currentUser != null) {
      usersInGroup = [
        currentUser!
      ]; // Add the current user (creator) by default
      userRoles[currentUser!.userName] = 'Administrator'; // Mark as Admin
    }

    if (group != null) {
      _loadGroupUsers(); // Load existing group users
      _loadInvitedUsers(); // Load invited users
    }
  }

  // Load users in the group
  Future<void> _loadGroupUsers() async {
    if (group == null) return;

    // Get users from group based on user IDs
    for (var id in group!.userIds) {
      final user = await _userService.getUserById(id);
      if (!usersInGroup.any((u) => u.id == user.id)) {
        usersInGroup.add(user); // Add user if not already in the list
      }
    }
    notifyListeners();
  }

  // Load invited users and set roles if they accepted the invitation
  void _loadInvitedUsers() {
    if (group?.invitedUsers != null) {
      group!.invitedUsers!.forEach((username, status) {
        if (status.invitationAnswer == true) {
          userRoles[username] = status.role;
        }
      });
    }
  }

  // Search users by username
  Future<void> searchUser(String query, BuildContext context) async {
    try {
      final result = await _userService.searchUsers(query.toLowerCase());
      if (result is List<String>) {
        // Filter out users already in the group
        searchResults = result.where((username) {
          return !usersInGroup.any((u) => u.userName == username) &&
              !userRoles.containsKey(username);
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Search error: $e');
      searchResults = [];
      notifyListeners();
      _showSnackBar(context, 'Error searching user');
    }
  }

  // Add a user to the group
  Future<void> addUser(String username, BuildContext context) async {
    try {
      final user = await _userService.getUserByUsername(username);

      // Don't add if the user is already in the group
      if (usersInGroup.any((u) => u.userName == username)) return;

      // Add the new user to the group
      usersInGroup.add(user);
      userRoles[user.userName] = 'Member'; // Default role for new users

      // Remove from the search results as the user is now added
      searchResults.remove(username);

      // Notify listeners to update the UI
      notifyListeners();
    } catch (e) {
      print('Add user error: $e');
      _showSnackBar(context, 'Error adding user');
    }
  }

  void removeUser(String username) {
    usersInGroup.removeWhere((u) => u.userName == username);
    userRoles.remove(username);
    notifyListeners();
  }

  void changeRole(String username, String newRole) {
    userRoles[username] = newRole;
    notifyListeners();
  }

  // Helper method to show SnackBar messages
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ThemeColors.getContainerBackgroundColor(
            context), // ✅ Dynamic background
        content: Text(
          message,
          style: TextStyle(
            color: ThemeColors.getTextColor(context), // ✅ Dynamic text color
            fontWeight:
                FontWeight.bold, // (optional) make snackbar text more visible
          ),
        ),
      ),
    );
  }

  // Other methods for removing and changing roles remain the same
}
