import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:flutter/material.dart';

class ProviderManagement extends ChangeNotifier {
  User? _currentUser;
  List<Group> _groups = [];
  ThemeData _themeData = lightTheme;
  bool _isLoadingGroups = false;

  //Getters
  User? get currentUser => _currentUser;
  List<Group> get groups => _groups;
  ThemeData get themeData => _themeData;
  bool get isLoadingGroups => _isLoadingGroups;

  set setLoadingGroups(bool value) {
    _isLoadingGroups = value;
    notifyListeners();
  }

  ProviderManagement({required User? user}) {
    _currentUser = user;
  }

  void setGroups(List<Group> groupsUpdated, {bool loading = false}) {
    _groups = groupsUpdated;
    setLoadingGroups = loading;
    notifyListeners();
  }

  // Method to add a group while avoiding duplicates
  void addGroupIfNotExists(Group group) {
    if (!_groups.any((existingGroup) => existingGroup.id == group.id)) {
      _groups.add(group);
      notifyListeners();
    }
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void initialize(User user, List<Group> groups) {
    _currentUser = user;
    _groups.addAll(groups);
    notifyListeners();
  }

  void updateUser(User newUser) {
    _currentUser = newUser;
    notifyListeners();
  }

  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void removeGroup(Group group) {
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups.removeAt(index);
      notifyListeners();
    }
  }

  void updateGroup(Group updatedGroup) {
    final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeData = (_themeData == lightTheme) ? darkTheme : lightTheme;
    notifyListeners();
  }
}
