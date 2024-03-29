import 'package:first_project/models/group.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:first_project/models/user.dart';

import 'package:flutter/foundation.dart';

class ProviderManagement extends ChangeNotifier {
  User? _currentUser;
  List<Group> _groups = [];
  ThemeData _themeData = lightTheme;

  User? get user => _currentUser;
  List<Group> get setGroups => _groups;
  ThemeData get themeData => _themeData;

  ProviderManagement({
    required User? user,
  }) {
    _currentUser = user;
  }

  set setGroups(groups) {
    _groups = groups;
  }

  // Method to set the currentUser
  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners(); // Notify the listeners (providers) of the change
  }

  // Initialize the user and groups
  void initialize(User user, List<Group> groups) {
    _currentUser = user;
    _groups = groups;
    notifyListeners();
  }

  // Update the user and notify listeners
  void updateUser(User newUser) {
    _currentUser = newUser;
    notifyListeners();
  }

  // Add a new group to the list
  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  // Remove a group from the list
  void removeGroupById(Group group) {
    _groups.removeWhere((group) => group.id == group.id);
    notifyListeners();
  }

  // Update a group in the list
  void updateGroup(Group updatedGroup) {
    final index = _groups.indexWhere((group) => group.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
    }
  }
  
  // Toggle the theme
  void toggleTheme() {
    _themeData = (_themeData == lightTheme) ? darkTheme : lightTheme;
    notifyListeners();
  }


  // // Get updated group by ID
  
  // Group getUpdatedGroup(String groupId) {
  //   return _groups.firstWhere((group) => group.id == groupId,
  //       orElse: () => throw Exception('Group not found with ID: $groupId'));
  // }
}
