import 'dart:async';

import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/firestore_database/logic_backend/firestore_service.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:flutter/material.dart';

class ProviderManagement extends ChangeNotifier {
  User? _currentUser;
  List<Group> _groups = [];
  ThemeData _themeData = lightTheme;
  late FirestoreService storeService;

  // Getters
  User? get currentUser => _currentUser;
  List<Group> get groups => _groups;
  ThemeData get themeData => _themeData;

  // Stream controller and stream for group updates
  final _groupController = StreamController<List<Group>>.broadcast();
  Stream<List<Group>> get groupStream => _groupController.stream;

  ProviderManagement({required User? user}) {
    _currentUser = user;
  }

  // Method to update the group stream with the latest list of groups
  void updateGroupStream(List<Group> groups) {
    _groupController.add(groups);
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void initialize(User user, List<Group> groups) {
    _currentUser = user;
    _groups.addAll(groups);
    notifyListeners();
    _groupController.add(_groups); // Add initial groups to the stream
  }

  void updateUser(User newUser) {
    _currentUser = newUser;
    notifyListeners();
  }

  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
    _groupController.add(_groups); // Add updated groups to the stream
  }

  void removeGroup(Group group) {
    _groups.removeWhere((g) => g.id == group.id);
    notifyListeners();
    _groupController.add(_groups); // Add updated groups to the stream
  }

  void updateGroup(Group updatedGroup) {
    final index = _groups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      _groups[index] = updatedGroup;
      notifyListeners();
      _groupController.add(_groups); // Add updated groups to the stream
    }
  }

  void toggleTheme() {
    _themeData = (_themeData == lightTheme) ? darkTheme : lightTheme;
    notifyListeners();
  }

  // Dispose the stream controller when no longer needed
  @override
  void dispose() {
    _groupController.close();
    super.dispose();
  }
}
