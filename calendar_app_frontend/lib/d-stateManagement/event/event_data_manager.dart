import 'dart:async';

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/event/event_group_resolver.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/b-backend/api/event/event_services.dart';
import 'package:calendar_app_frontend/b-backend/api/socket/socket_manager.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/repetition_dialog/utils/show_recurrence.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:flutter/material.dart';

/// Manages the event cache for a single group.
/// Stores only base events (no pre‑expanded recurrences).
/// Expands recurring events on‑demand for a visible date range.
class EventDataManager {
  List<Event> _baseEvents = [];

  late final Group _group;
  final EventService _eventService;
  final GroupManagement _groupManagement;
  final GroupEventResolver _resolver;

  final StreamController<List<Event>> _eventsController =
      StreamController<List<Event>>.broadcast();

  void Function()? onExternalEventUpdate;

  final ValueNotifier<List<Event>> eventsNotifier = ValueNotifier([]);

  EventDataManager(
    List<Event> initialEvents, {
    required Group group,
    required EventService eventService,
    required GroupManagement groupManagement,
    required GroupEventResolver resolver,
  })  : _group = group,
        _eventService = eventService,
        _groupManagement = groupManagement,
        _resolver = resolver {
    _initialize(initialEvents);
    _setupSocketListeners();
  }

  Future<void> _initialize(List<Event> initial) async {
    _baseEvents = _deduplicate(initial);
    await _refreshFromBackend();
  }

  void _setupSocketListeners() {
    final socket = SocketManager().socket;

    socket.on('event:created', (data) {
      final created = Event.fromJson(data);
      _baseEvents = _deduplicate([..._baseEvents, created]);
      _notifyChanges();
    });

    socket.on('event:updated', (data) {
      final updated = Event.fromJson(data);
      _baseEvents =
          _baseEvents.map((e) => e.id == updated.id ? updated : e).toList();
      _notifyChanges();
    });

    socket.on('event:deleted', (data) {
      final deletedId = data['id'];
      _baseEvents.removeWhere((e) => e.id == deletedId);
      _notifyChanges();
    });
  }

  List<Event> get baseEvents => _baseEvents;
  Stream<List<Event>> get eventsStream => _eventsController.stream;

  Future<void> manualRefresh() async => _refreshFromBackend();

  Future<List<Event>> fetchAllEvents() async {
    final fresh = await _resolver.getEventsForGroup(_group);
    _baseEvents = _deduplicate(fresh);
    _notifyChanges();
    return _baseEvents;
  }

  Future<Event?> fetchEvent(String id, {String? fallbackId}) async {
    try {
      return await _eventService.getEventById(id);
    } catch (e) {
      if (fallbackId != null) {
        debugPrint('⚠️ Fallback to original ID: $fallbackId');
        return await _eventService.getEventById(fallbackId);
      }
      rethrow;
    }
  }

  Future<Event> createEvent(Event event) async {
    final created = await _eventService.createEvent(event);
    _baseEvents = _deduplicate([..._baseEvents, created]);
    _notifyChanges();
    return created;
  }

  Future<Event> updateEvent(Event event) async {
    await _eventService.updateEvent(event.id, event.toBackendJson());
    final fresh = await _eventService.getEventById(event.id);
    _baseEvents = _deduplicate(
      _baseEvents.map((e) => e.id == fresh.id ? fresh : e).toList(),
    );
    _notifyChanges();
    return fresh;
  }

  Future<void> deleteEvent(String id) async {
    await _eventService.deleteEvent(id);
    _baseEvents.removeWhere((e) => e.id == id);
    _notifyChanges();
  }

  /// All events intersecting a single day
  List<Event> getEventsForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _baseEvents.where((e) {
      return e.startDate.isBefore(dayEnd) && e.endDate.isAfter(dayStart);
    }).toList();
  }

  /// Return only events that intersect the [range]. Recurring events are
  /// expanded *on‑demand* via `expandRecurringEventForRange`.
  List<Event> getEventsForRange(DateTimeRange range) {
    final List<Event> result = [];

    for (final event in _baseEvents) {
      if (event.recurrenceRule == null) {
        if (_overlapsRange(event.startDate, event.endDate, range)) {
          result.add(event);
        }
      } else {
        result.addAll(expandRecurringEventForRange(event, range));
      }
    }

    return _deduplicate(result);
  }

  /// 🔁 Alias for clarity: "give me expanded events inside this date range"
  List<Event> getExpandedEvents(DateTimeRange range) =>
      getEventsForRange(range);

  Future<void> _refreshFromBackend() async {
    if (_group.id == Group.createDefaultGroup().id) return;
    _baseEvents = _deduplicate(await _resolver.getEventsForGroup(_group));
    _notifyChanges();
  }

  void _notifyChanges() {
    _groupManagement.currentGroup = _group;

    final now = DateTime.now();
    final visibleRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(const Duration(days: 365)),
    );

    final expanded = getExpandedEvents(visibleRange);

    // 🔎 Debug: print what’s going on
    for (final e in _baseEvents) {
      if (e.recurrenceRule != null) {
        // print('🔁 Event "${e.title}" has rule: ${e.rule}');
        final instances = expandRecurringEventForRange(e, visibleRange);
        // print('  → ${instances.length} occurrences generated');
      }
    }

    _eventsController.add(expanded);
    eventsNotifier.value = List.unmodifiable(expanded);

    onExternalEventUpdate?.call();
    _resolver.updateCache(_group.id, _baseEvents);
  }

  List<Event> _deduplicate(List<Event> list) =>
      {for (var e in list) e.id: e}.values.toList();

  bool _overlapsRange(DateTime start, DateTime end, DateTimeRange range) =>
      start.isBefore(range.end) && end.isAfter(range.start);

  void dispose() {
    _eventsController.close();
    eventsNotifier.dispose();
  }

  /// 👇 Legacy support method – used in older parts of the UI
  Future<void> removeGroupEvents({required Event event}) =>
      deleteEvent(event.id);
}
