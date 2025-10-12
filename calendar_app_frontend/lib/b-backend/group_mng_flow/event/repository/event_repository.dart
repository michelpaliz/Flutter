// lib/b-backend/core/event/repository/event_repository.dart
import 'dart:async';

import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/b-backend/group_mng_flow/event/api/i_event_api_client.dart';
import 'package:hexora/b-backend/group_mng_flow/event/repository/i_event_repository.dart';
import 'package:hexora/b-backend/group_mng_flow/event/string_utils.dart';

class EventRepository implements IEventRepository {
  EventRepository({
    required IEventApiClient apiClient,
    required TokenSupplier tokenSupplier,
  })  : _api = apiClient,
        _token = tokenSupplier;

  final IEventApiClient _api;
  final TokenSupplier _token;

  // ---- In-memory cache + per-group streams ---------------------------------
  final Map<String, List<Event>> _cacheByGroupId = {};
  final Map<String, StreamController<List<Event>>> _controllers = {};

  StreamController<List<Event>> _ctrlFor(String groupId) =>
      _controllers.putIfAbsent(groupId, () => StreamController.broadcast());

  List<Event> _getCache(String groupId) =>
      _cacheByGroupId[groupId] ?? const <Event>[];

  void _emit(String groupId, List<Event> next) {
    _cacheByGroupId[groupId] = next;
    final c = _ctrlFor(groupId);
    if (!c.isClosed) c.add(List.unmodifiable(next));
  }

  List<Event> _dedupe(List<Event> list) =>
      {for (final e in list) baseId(e.id): e}.values.toList();

  // Helper: safe groupId
  /// Returns the groupId of the given event, or null if not present.
  /// Useful when you don't know the group ID of an event beforehand.
  /// (e.g., when handling events from a socket or cached data)
  String? _gidOf(Event e) {
    final gid = e.groupId;
    return (gid != null && gid.isNotEmpty) ? gid : null;
  }

  // Public stream
  Stream<List<Event>> events$(String groupId) {
    final c = _ctrlFor(groupId);
    // emit snapshot to new listeners
    scheduleMicrotask(() {
      final snap = _getCache(groupId);
      if (snap.isNotEmpty && !c.isClosed) c.add(List.unmodifiable(snap));
    });
    return c.stream;
  }

  // ---- Refresh (authoritative) ---------------------------------------------
  Future<void> refreshGroup(String groupId) async {
    final token = await _token();
    final fetched = await _api.getEventsByGroupId(groupId, token);
    _emit(groupId, _dedupe(fetched));
  }

  // ---- CRUD (keeps cache in sync and emits) --------------------------------
  @override
  Future<Event> createEvent(Event event) async {
    final token = await _token();
    final created = await _api.createEvent(event, token);
    final gid = _gidOf(created);
    if (gid != null) {
      final next = _dedupe([..._getCache(gid), created]);
      _emit(gid, next);
    }
    return created;
  }

  @override
  Future<Event> getEventById(String id) async =>
      _api.getEventById(id, await _token());

  @override
  Future<Event> updateEvent(Event ev) async {
    final token = await _token();
    final updated = await _api.updateEvent(ev, token);
    final gid = _gidOf(updated);
    if (gid != null) {
      final next = _getCache(gid)
          .map((e) => baseId(e.id) == baseId(updated.id) ? updated : e)
          .toList();
      _emit(gid, _dedupe(next));
    }
    return updated;
  }

  @override
  Future<Event> markEventAsDone(String id, {required bool isDone}) async {
    final token = await _token();
    final updated = await _api.markEventAsDone(
      id,
      isDone: isDone,
      token: token,
    );
    final gid = _gidOf(updated);
    if (gid != null) {
      final next = _getCache(gid)
          .map((e) => baseId(e.id) == baseId(updated.id) ? updated : e)
          .toList();
      _emit(gid, _dedupe(next));
    }
    return updated;
  }

  @override
  Future<void> deleteEvent(String id) async {
    final token = await _token();
    await _api.deleteEvent(id, token);
    // We don’t know groupId directly; try to remove from any group cache
    final key = baseId(id);
    for (final gid in _cacheByGroupId.keys.toList()) {
      final before = _getCache(gid);
      final after = before
          .where((e) => baseId(e.id) != key && baseId(e.rawRuleId ?? '') != key)
          .toList();
      if (after.length != before.length) {
        _emit(gid, _dedupe(after));
      }
    }
  }

  @override
  Future<List<Event>> getEventsByGroupId(String groupId) async {
    final token = await _token();
    return _api.getEventsByGroupId(groupId, token);
  }

  // ---- Socket hooks (optional but handy) -----------------------------------
  void onSocketCreated(String groupId, Map<String, dynamic> json) {
    final created = Event.fromJson(json);
    final gid = _gidOf(created);
    if (gid == null || gid != groupId) return;
    _emit(groupId, _dedupe([..._getCache(groupId), created]));
  }

  void onSocketUpdated(String groupId, Map<String, dynamic> json) {
    final updated = Event.fromJson(json);
    final gid = _gidOf(updated);
    if (gid == null || gid != groupId) return;
    final next = _getCache(groupId)
        .map((e) => baseId(e.id) == baseId(updated.id) ? updated : e)
        .toList();
    _emit(groupId, _dedupe(next));
  }

  void onSocketDeleted(String groupId, Map<String, dynamic> json) {
    final deletedId = baseId(json['id']?.toString() ?? '');
    if (deletedId.isEmpty) return;
    final after = _getCache(groupId)
        .where((e) =>
            baseId(e.id) != deletedId && baseId(e.rawRuleId ?? '') != deletedId)
        .toList();
    _emit(groupId, _dedupe(after));
  }

  // ---- Cleanup --------------------------------------------------------------
  void dispose() {
    for (final c in _controllers.values) {
      if (!c.isClosed) c.close();
    }
    _controllers.clear();
    _cacheByGroupId.clear();
  }
}
