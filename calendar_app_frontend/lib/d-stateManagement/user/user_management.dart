import 'dart:async';
import 'dart:math';

import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:calendar_app_frontend/b-backend/api/user/user_services.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:flutter/material.dart';

class UserManagement extends ChangeNotifier {
  User? _user;
  final UserService userService = UserService();
  final NotificationManagement _notificationManagement;
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

  Timer? _avatarRefreshTimer; // ⬅️ NEW

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

  void setCurrentUser(User? user, {String? authToken}) {
    debugPrint('👤 setCurrentUser called with: $user');
    _stopAvatarRefreshTimer();

    if (user != null) {
      updateCurrentUser(user, authToken: authToken);

      // Only start timer if avatars are private
      if (!ApiConstants.avatarsArePublic && authToken != null) {
        _startAvatarRefreshTimer(authToken);
      }
    } else {
      _user = null;
      currentUserNotifier.value = null;
      notifyListeners();
    }
  }

  void updateCurrentUser(User user, {String? authToken}) {
    _user = user;
    currentUserNotifier.value = user;
    _initNotifications(user);

    // Only refresh if private avatars
    if (!ApiConstants.avatarsArePublic && authToken != null) {
      refreshUserAvatarUrlIfNeeded(authToken);
    }

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

  Future<void> refreshUserAvatarUrlIfNeeded(String authToken) async {
    if (_user?.photoBlobName == null) return;
    final expiry = _extractExpiryTime(_user!.photoUrl ?? "");
    final now = DateTime.now().toUtc();

    if (expiry == null || expiry.difference(now).inMinutes < 5) {
      try {
        final freshUrl = await userService.getFreshAvatarUrl(
          blobName: _user!.photoBlobName!,
          authToken: authToken,
        );
        _user = _user!.copyWith(photoUrl: freshUrl);
        currentUserNotifier.value = _user;
        notifyListeners();
        debugPrint('🔄 User avatar URL refreshed');
      } catch (e) {
        debugPrint('❌ Failed to refresh avatar URL: $e');
      }
    }
  }

  DateTime? _extractExpiryTime(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final seParam = uri.queryParameters['se'];
    return seParam != null
        ? DateTime.tryParse(Uri.decodeComponent(seParam))
        : null;
  }

  // --------------------------
  // Periodic refresh functions
  // --------------------------
  void _startAvatarRefreshTimer(String authToken) {
    _avatarRefreshTimer = Timer.periodic(
      const Duration(minutes: 4),
      (_) => refreshUserAvatarUrlIfNeeded(authToken),
    );
    debugPrint('⏳ Avatar refresh timer started');
  }

  void _stopAvatarRefreshTimer() {
    _avatarRefreshTimer?.cancel();
    _avatarRefreshTimer = null;
    debugPrint('🛑 Avatar refresh timer stopped');
  }

  @override
  void dispose() {
    _stopAvatarRefreshTimer();
    currentUserNotifier.dispose();
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
