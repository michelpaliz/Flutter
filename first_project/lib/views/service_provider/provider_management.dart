import 'package:first_project/models/group.dart';
import 'package:flutter/material.dart';
import 'package:first_project/models/user.dart';

import 'package:flutter/foundation.dart';

class ProviderManagement extends ChangeNotifier {
  User? _user;
  List<Group> _groups = [];

  User? get user => _user;
  List<Group> get groups => _groups;

  ProviderManagement({
    required User user,
  }) {
    _user = user;
  }

  set groups(groups) {
    _groups = groups;
  }

  // Initialize the user and groups
  void initialize(User user, List<Group> groups) {
    _user = user;
    _groups = groups;
    notifyListeners();
  }

  // Update the user and notify listeners
  void updateUser(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  // Add a new group to the list
  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  // Remove a group from the list
  void removeGroup(Group group) {
    _groups.remove(group);
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
}
