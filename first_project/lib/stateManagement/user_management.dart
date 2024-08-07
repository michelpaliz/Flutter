import 'dart:async';

import 'package:first_project/models/user.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:flutter/material.dart';

class UserManagement extends ChangeNotifier {
  User? _currentUser;
  final UserService userService = UserService();
  final NotificationManagement notificationManagement;
  final _userController = StreamController<User?>.broadcast();
  Stream<User?> get userStream => _userController.stream;

  User? get currentUser => _currentUser;

  UserManagement({required User? user, required this.notificationManagement}) {
    _currentUser = user;
    if (user != null) {
      _initNotifications(user);
    }
  }

// In the provided code, updateCurrentUser already performs the tasks of setting the current user, updating the stream, initializing notifications if the user is not null, and notifying listeners. Therefore, there is no need for a separate setCurrentUser method unless you want to add more specific behavior to distinguish between setting and updating the current user.

  void setCurrentUser(User? user) {
    updateCurrentUser(user);
  }

  void _initNotifications(User user) {
    notificationManagement.initNotifications(user.notifications);
  }

  void updateCurrentUser(User? user) {
    _currentUser = user;
    _userController.add(user);
    if (user != null) {
      _initNotifications(user);
    }
    notifyListeners();
  }

  Future<void> updateCostumeUser(User? userUpdated) async {
    if (userUpdated != null) {
      _currentUser = userUpdated;
      if (userUpdated.email.isNotEmpty) {
        try {
          final userFromService =
              await userService.getUserByEmail(userUpdated.email);
          _currentUser = userFromService;
          updateCurrentUser(_currentUser);
        } catch (e) {
          print('Failed to update user: $e');
        }
      }
      notifyListeners();
    }
  }

  Future<bool> getUser() async {
    try {
      await userService.getUserByUsername(_currentUser!.userName);
      return true;
    } catch (e) {
      print('Failed to get User: $e');
      return false;
    }
  }

  Future<bool> updateUser(User newUser) async {
    try {
      await userService.updateUser(newUser);
      if (_currentUser != null) {
        if (newUser.id == _currentUser!.id) {
          _currentUser = newUser;
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      print('Failed to update the user: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _userController.close();
    super.dispose();
  }
}
