// user_management.dart
import 'dart:async';
import 'dart:math';

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/agenda/agenda_services.dart'; // 👈 NEW
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:calendar_app_frontend/b-backend/api/user/user_services.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:flutter/material.dart';

class UserManagement extends ChangeNotifier {
  User? _user;
  final UserService userService = UserService();
  final AgendaService _agendaService; // 👈 NEW
  final NotificationManagement _notificationManagement;
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

  Timer? _avatarRefreshTimer;

  User? get user => _user;

  UserManagement({
    required User? user,
    required NotificationManagement notificationManagement,
    AgendaService? agendaService, // 👈 allow DI (tests)
  })  : _notificationManagement = notificationManagement,
        _agendaService = agendaService ?? AgendaService() {
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

  // --------------------------
  // Avatar refresh (private)
  // --------------------------
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

  // --------------------------
  // ✅ Agenda convenience API
  // --------------------------

  /// Get upcoming agenda for the logged-in user (server-side union of events where user is owner/recipient).
  Future<List<Event>> fetchAgendaUpcoming({
    int days = 14,
    int limit = 200,
    String? tz,
  }) async {
    return _agendaService.fetchUpcoming(days: days, limit: limit, tz: tz);
  }

  /// Get agenda for a date range.
  Future<List<Event>> fetchAgendaRange({
    required DateTime from,
    required DateTime to,
    String? tz,
    int? limit,
  }) async {
    return _agendaService.fetchRange(from: from, to: to, tz: tz, limit: limit);
  }

  /// Convenience: today + tomorrow.
  Future<List<Event>> fetchAgendaTodayAndTomorrow({String? tz}) {
    return _agendaService.fetchTodayAndTomorrow(tz: tz);
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
