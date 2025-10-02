// user_management.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/api/agenda/agenda_services.dart' show AgendaService;
import 'package:hexora/b-backend/api/agenda/query_knobs/client_rollup.dart';
import 'package:hexora/b-backend/api/agenda/query_knobs/work_summary.dart';
import 'package:hexora/b-backend/api/config/api_constants.dart';
import 'package:hexora/b-backend/api/user/user_services.dart';
import 'package:hexora/d-stateManagement/notification/notification_management.dart';

class UserManagement extends ChangeNotifier {
  User? _user;
  final UserService userService = UserService();
  final AgendaService _agendaService;
  final NotificationManagement _notificationManagement;
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

  Timer? _avatarRefreshTimer;

  User? get user => _user;

  UserManagement({
    required User? user,
    required NotificationManagement notificationManagement,
    AgendaService? agendaService, // allow DI (tests)
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
      return await userService.getUserBySelector(_user!.userName);
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
  // ✅ Agenda convenience API (single /agenda/work)
  // --------------------------

  /// Raw upcoming items for a group (now requires groupId).
  Future<List<Event>> fetchAgendaUpcoming({
    required String groupId,
    int days = 14,
    int limit = 200,
    String? tz,
  }) {
    return _agendaService.fetchUpcoming(
      groupId: groupId,
      days: days,
      limit: limit,
      tz: tz,
    );
  }

  /// Raw items in a date range for a group.
  Future<List<Event>> fetchAgendaRange({
    required String groupId,
    required DateTime from,
    required DateTime to,
    String? tz,
    int? limit,
  }) {
    return _agendaService.fetchRange(
      groupId: groupId,
      from: from,
      to: to,
      tz: tz,
      limit: limit,
    );
  }

  /// Today + tomorrow items for a group (re-implemented here).
  Future<List<Event>> fetchAgendaTodayAndTomorrow({
    required String groupId,
    String? tz,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day); // local midnight
    final end = start.add(const Duration(days: 2)); // end of tomorrow (exclusive)
    return _agendaService.fetchWorkItems(
      groupId: groupId,
      from: start,
      to: end,
      tz: tz,
    );
  }

  /// Raw work items (aggregate=none).
  Future<List<Event>> fetchWorkItems({
    required String groupId,
    required DateTime from,
    required DateTime to,
    List<String> types = const ['work_visit'],
    List<String>? clientIds,
    List<String>? serviceIds,
    int? limit,
    int? skip,
    String? tz,
  }) {
    return _agendaService.fetchWorkItems(
      groupId: groupId,
      from: from,
      to: to,
      types: types,
      clientIds: clientIds,
      serviceIds: serviceIds,
      limit: limit,
      skip: skip,
      tz: tz,
    );
  }

  /// Summary (total events, minutes/hours) for any window.
  /// minutesSource: 'auto' | 'planned' | 'actual'
  Future<WorkSummary> fetchWorkSummary({
    required String groupId,
    required DateTime from,
    required DateTime to,
    List<String> types = const ['work_visit'],
    List<String>? clientIds,
    List<String>? serviceIds,
    String minutesSource = 'auto',
    String? tz,
  }) {
    return _agendaService.fetchWorkSummary(
      groupId: groupId,
      from: from,
      to: to,
      types: types,
      clientIds: clientIds,
      serviceIds: serviceIds,
      minutesSource: minutesSource,
      tz: tz,
    );
  }

  /// Rollup by client for any window.
  Future<List<ClientRollup>> fetchWorkByClient({
    required String groupId,
    required DateTime from,
    required DateTime to,
    List<String> types = const ['work_visit'],
    List<String>? clientIds,
    List<String>? serviceIds,
    int? limit,
    int? skip,
    String minutesSource = 'auto',
    String? tz,
  }) {
    return _agendaService.fetchWorkByClient(
      groupId: groupId,
      from: from,
      to: to,
      types: types,
      clientIds: clientIds,
      serviceIds: serviceIds,
      limit: limit,
      skip: skip,
      minutesSource: minutesSource,
      tz: tz,
    );
  }

  /// Rollup by service for any window.
  Future<List<ServiceRollup>> fetchWorkByService({
    required String groupId,
    required DateTime from,
    required DateTime to,
    List<String> types = const ['work_visit'],
    List<String>? clientIds,
    List<String>? serviceIds,
    int? limit,
    int? skip,
    String minutesSource = 'auto',
    String? tz,
  }) {
    return _agendaService.fetchWorkByService(
      groupId: groupId,
      from: from,
      to: to,
      types: types,
      clientIds: clientIds,
      serviceIds: serviceIds,
      limit: limit,
      skip: skip,
      minutesSource: minutesSource,
      tz: tz,
    );
  }

  /// Past hours summary (uses minutesSource='auto').
  Future<WorkSummary> pastHours({
    required String groupId,
    required DateTime from,
    required DateTime to,
    List<String> types = const ['work_visit'],
    List<String>? clientIds,
    List<String>? serviceIds,
  }) {
    return _agendaService.pastHours(
      groupId: groupId,
      from: from,
      to: to,
      types: types,
      clientIds: clientIds,
      serviceIds: serviceIds,
    );
  }

  /// Future forecast summary (uses minutesSource='planned').
  Future<WorkSummary> futureForecast({
    required String groupId,
    required DateTime from,
    required DateTime to,
    List<String> types = const ['work_visit'],
    List<String>? clientIds,
    List<String>? serviceIds,
  }) {
    return _agendaService.futureForecast(
      groupId: groupId,
      from: from,
      to: to,
      types: types,
      clientIds: clientIds,
      serviceIds: serviceIds,
    );
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
