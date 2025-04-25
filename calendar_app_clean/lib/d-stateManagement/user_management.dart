import 'dart:math';

import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:flutter/material.dart';

class UserManagement extends ChangeNotifier {
  User? _user;
  final UserService userService = UserService();
  final NotificationManagement _notificationManagement;

  // ✅ Switched from StreamController to ValueNotifier
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

  User? get user => _user;

  UserManagement({
    required User? user,
    required NotificationManagement notificationManagement,
  }) : _notificationManagement = notificationManagement {
    if (user != null) {
      setCurrentUser(user);
    }
  }

  Future<List<User>> getUsersForGroup(Group group) async {
    return await Future.wait(
      group.userIds.map((userId) => userService.getUserById(userId)),
    );
  }

  void setCurrentUser(User? user) {
    debugPrint('👤 setCurrentUser called with: $user');

    if (user != null) {
      updateCurrentUser(user); // Use consistent update flow
    } else {
      _user = null;
      currentUserNotifier.value = null;
      notifyListeners();
    }
  }

  void updateCurrentUser(User user) {
    _user = user;
    currentUserNotifier.value = user;
    _initNotifications(user);
    notifyListeners();
  }

  void _initNotifications(User user) {
    final notificationIds = user.notifications;
    debugPrint("Initializing notifications: $notificationIds");
    _notificationManagement.initNotifications(notificationIds);
  }

  Future<void> updateUserFromDB(User? updatedUser) async {
    if (updatedUser == null) return;

    try {
      final userFromService =
          await userService.getUserByEmail(updatedUser.email);
      updateCurrentUser(userFromService);
    } catch (e) {
      debugPrint('❌ Failed to update user: $e');
    }
  }

  Future<User?> getUser() async {
    if (_user == null) return null;

    try {
      return await userService.getUserByUsername(_user!.userName);
    } catch (e) {
      debugPrint('❌ Failed to get user: $e');
      return null;
    }
  }

  Future<bool> updateUser(User updatedUser) async {
    try {
      await userService.updateUser(updatedUser);

      if (_user != null && updatedUser.id == _user!.id) {
        updateCurrentUser(updatedUser);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Failed to update user: $e');
      return false;
    }
  }

  @override
  void dispose() {
    currentUserNotifier.dispose(); // Clean up
    super.dispose();
  }
}

// Utility
String generateCustomId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      10,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}
