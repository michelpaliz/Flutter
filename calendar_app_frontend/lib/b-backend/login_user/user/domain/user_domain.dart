import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/agenda/agenda_api_client.dart'
    show AgendaApiClient;
import 'package:hexora/b-backend/agenda/query_knobs/client_rollup.dart';
import 'package:hexora/b-backend/agenda/query_knobs/work_summary.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:hexora/b-backend/login_user/user/api/user_api_client.dart';
import 'package:hexora/b-backend/login_user/user/repository/user_repository.dart';
import 'package:hexora/b-backend/notification/domain/notification_domain.dart';

class UserDomain extends ChangeNotifier {
  User? _user;

  // 🔄 Use repository (service is injected into it)
  final UserRepository userRepository = UserRepository(UserApiClient());

  final AgendaApiClient _agendaService;
  final NotificationDomain _notificationDomain;
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier(null);

  Timer? _avatarRefreshTimer;

  User? get user => _user;

  UserDomain({
    required User? user,
    required NotificationDomain notificationDomain,
    AgendaApiClient? agendaService,
  })  : _notificationDomain = notificationDomain,
        _agendaService = agendaService ?? AgendaApiClient() {
    if (user != null) {
      setCurrentUser(user);
    }
  }

  // ---------- Helpers for other parts of the app ----------
  Future<List<User>> getUsersForGroup(Group group) async {
    return userRepository.getUsersForGroup(group);
  }

  // Small pass-throughs (so existing code compiles without big changes)
  Future<User> getUserById(String id) => userRepository.getUserById(id);
  Future<User> getUserByUsername(String username) =>
      userRepository.getUserByUsername(username);

  // ---------- User state ----------
  void setCurrentUser(User? user) {
    debugPrint('👤 setCurrentUser called with: $user');
    _stopAvatarRefreshTimer();

    if (user != null) {
      updateCurrentUser(user);

      // If avatars are private, keep a periodic refresh (token handled in repo)
      if (!ApiConstants.avatarsArePublic) {
        _startAvatarRefreshTimer();
      }
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

    // Try an immediate avatar refresh if private blobs
    if (!ApiConstants.avatarsArePublic) {
      refreshUserAvatarUrlIfNeeded();
    }

    notifyListeners();
  }

  void _initNotifications(User user) {
    final notificationIds = user.notifications;
    debugPrint("Initializing notifications: $notificationIds");
    _notificationDomain.initNotifications(notificationIds);
  }

  Future<void> updateUserFromDB(User? updatedUser) async {
    if (updatedUser == null) return;
    try {
      final userFromService =
          await userRepository.getUserByEmail(updatedUser.email);
      updateCurrentUser(userFromService);
    } catch (e) {
      debugPrint('❌ Failed to update user: $e');
    }
  }

  Future<User?> getUser() async {
    if (_user == null) return null;
    try {
      return await userRepository.getUserBySelector(_user!.userName);
    } catch (e) {
      debugPrint('❌ Failed to get user: $e');
      return null;
    }
  }

  Future<bool> updateUser(User updatedUser) async {
    try {
      final saved = await userRepository.updateUser(updatedUser);
      if (_user != null && saved.id == _user!.id) {
        updateCurrentUser(saved);
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
  Future<void> refreshUserAvatarUrlIfNeeded() async {
    if (_user?.photoBlobName == null) return;
    final expiry = _extractExpiryTime(_user!.photoUrl ?? "");
    final now = DateTime.now().toUtc();

    // refresh when missing or expiring soon
    if (expiry == null || expiry.difference(now).inMinutes < 5) {
      try {
        final freshUrl = await userRepository.getFreshAvatarUrl(
          blobName: _user!.photoBlobName!,
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

  void _startAvatarRefreshTimer() {
    _avatarRefreshTimer?.cancel();
    _avatarRefreshTimer = Timer.periodic(
      const Duration(minutes: 4),
      (_) => refreshUserAvatarUrlIfNeeded(),
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

  Future<List<Event>> fetchAgendaTodayAndTomorrow({
    required String groupId,
    String? tz,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 2));
    return _agendaService.fetchWorkItems(
      groupId: groupId,
      from: start,
      to: end,
      tz: tz,
    );
  }

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

  // user_repository.dart (add inside class)
  Future<void> uploadAndCommitUserAvatar({
    required String userId,
    required File file,
  }) async {
    // 1) uploadImageToAzure(scope: 'users', resourceId: userId, ...)
    // 2) PATCH ${ApiConstants.baseUrl}/users/$userId/photo  { "blobName": "<from upload>" }
    // (Fetch token internally via TokenStorage — keep UI clean)
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
