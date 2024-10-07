import 'dart:async';

import 'package:first_project/a-models/model/DTO/userDTO.dart';
import 'package:first_project/a-models/model/user_data/user.dart'; // Import your User model
import 'package:first_project/b-backend/database_conection/node_services/user_services.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:flutter/material.dart';

class UserManagement extends ChangeNotifier {
  User? _user; // Change from UserDTO to User
  final UserService userService = UserService();
  final NotificationManagement _notificationManagement;
  final _userController =
      StreamController<User?>.broadcast(); // Change Stream type to User
  Stream<User?> get userStream => _userController.stream;

  User? get user => _user;

  UserManagement({
    required UserDTO? userDTO, // Accept UserDTO
    required NotificationManagement notificationManagement,
  }) : _notificationManagement = notificationManagement {
    if (userDTO != null) {
      setCurrentUser(userDTO);
    }
  }

  void setCurrentUser(UserDTO? user) {
    if (user != null) {
      updateCurrentUser(user);
    }
  }

  void _initNotifications(UserDTO userDTO) {
    // Convert UserDTO to User
    User user = userDTO.toUser();

    // Ensure the notifications are in the correct format (List<String> IDs)
    List<String> notificationIds = user.notifications
        .map((notification) =>
            notification['id']) // Assuming notification has an 'id' field
        .toList();

    // Initialize notifications using the notification IDs
    _notificationManagement.initNotifications(notificationIds);
  }

  void updateCurrentUser(UserDTO? userDTO) {
    if (userDTO != null) {
      // Convert UserDTO to User
      _userController.add(userDTO.toUser());
      _initNotifications(userDTO); // Initialize notifications for the DTO
      notifyListeners();
    }
  }

  Future<void> updateUserFromDB(UserDTO? userUpdatedDTO) async {
    if (userUpdatedDTO != null) {
      try {
        final userFromService =
            await userService.getUserByEmail(userUpdatedDTO.email);
        updateCurrentUser(
            userFromService.toDTO()); // Update using the converted User object
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
    // Accept User instead of UserDTO
    try {
      // Convert User to UserDTO
      await userService
          .updateUser(updatedUser.toDTO()); // Update to use UserDTO
      if (_user != null) {
        if (updatedUser.id == _user!.id) {
          updateCurrentUser(
              updatedUser.toDTO()); // Convert back to User and update
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
