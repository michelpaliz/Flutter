import 'dart:async';
import 'package:first_project/a-models/model/user_data/user.dart'; // Import your User model
import 'package:first_project/b-backend/database_conection/node_services/user_services.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:flutter/material.dart';

class UserManagement extends ChangeNotifier {
  User? _user;
  final UserService userService = UserService();
  final NotificationManagement _notificationManagement;
  final _userController = StreamController<User?>.broadcast();
  
  Stream<User?> get userStream => _userController.stream;

  User? get user => _user;

  UserManagement({
    required User? user, // Accept User directly
    required NotificationManagement notificationManagement,
  }) : _notificationManagement = notificationManagement {
    if (user != null) {
      setCurrentUser(user);
    }
  }

  void setCurrentUser(User? user) {
    if (user != null) {
      updateCurrentUser(user);
    }
  }

void _initNotifications(User user) {
  // Ensure the notifications are in the correct format (List<String> IDs)
  List<String> notificationIds = user.notifications!
      .map((notification) => notification) // Access the 'id' field directly from NotificationUser object
      .toList();

  // Initialize notifications using the notification IDs
  _notificationManagement.initNotifications(notificationIds);
}


  void updateCurrentUser(User? user) {
    if (user != null) {
      _userController.add(user);
      _initNotifications(user);
      notifyListeners();
    }
  }

  Future<void> updateUserFromDB(User? updatedUser) async {
    if (updatedUser != null) {
      try {
        final userFromService = await userService.getUserByEmail(updatedUser.email);
        updateCurrentUser(userFromService); // Update directly with the User object
      } catch (e) {
        print('Failed to update user: $e');
      }
    }
  }

  Future<User?> getUser() async {
    try {
      return await userService.getUserByUsername(_user!.userName);
    } catch (e) {
      print('Failed to get User: $e');
      return null;
    }
  }

  Future<bool> updateUser(User updatedUser) async {
    try {
      await userService.updateUser(updatedUser); // Directly use User for updating
      if (_user != null) {
        if (updatedUser.id == _user!.id) {
          updateCurrentUser(updatedUser);
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
