import 'dart:async';

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/event/event_group_resolver.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/b-backend/api/event/event_services.dart';
import 'package:calendar_app_frontend/b-backend/api/socket/socket_events.dart';
import 'package:calendar_app_frontend/b-backend/api/socket/socket_manager.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/repetition_dialog/utils/show_recurrence.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_notification_helper.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:flutter/material.dart';

/// Manages the event cache for a single group.
/// Stores only base events (no pre‑expanded recurrences).
/// Expands recurring events on‑demand for a visible date range.
class EventDataManager {
  // Core data and dependencies
  List<Event> _baseEvents = [];
  late final Group _group;
  final EventService _eventService;
  final GroupManagement _groupManagement;
  final GroupEventResolver _resolver;

  // Reactive mechanisms
  final ValueNotifier<List<Event>> eventsNotifier = ValueNotifier([]);
  final StreamController<List<Event>> _eventsController =
      StreamController<List<Event>>.broadcast(); 

  void Function()? onExternalEventUpdate;

  /// Constructor
  EventDataManager(
    List<Event> initialEvents, {
    required BuildContext context,
    required Group group,
    required EventService eventService,
    required GroupManagement groupManagement,
    required GroupEventResolver resolver,
  })  : _group = group,
        _eventService = eventService,
        _groupManagement = groupManagement,
        _resolver = resolver {
    _initialize(context, initialEvents);
    _setupSocketListeners();
  }

  /// Initializes the manager with base events and fresh sync from backend.
  Future<void> _initialize(BuildContext context, List<Event> initial) async {
    _baseEvents = _deduplicate(initial);
    await _refreshFromBackend(context);
  }

  /// Subscribes to socket events (create/update/delete) and applies changes locally.
  void _setupSocketListeners() {
    final socketManager = SocketManager();

    socketManager.on(SocketEvents.created, (data) {
      final created = Event.fromJson(data);
      _baseEvents = _deduplicate([..._baseEvents, created]);
      _notifyChanges();
    });

    socketManager.on(SocketEvents.updated, (data) {
      final updated = Event.fromJson(data);
      _baseEvents =
          _baseEvents.map((e) => e.id == updated.id ? updated : e).toList();
      _notifyChanges();
    });

    socketManager.on(SocketEvents.deleted, (data) {
      final deletedId = data['id'];
      _baseEvents.removeWhere((e) => e.id == deletedId);
      _notifyChanges();
    });
  }

  /// Fetches all events from the resolver and updates internal state.
  Future<List<Event>> fetchAllEvents() async {
    final fresh = await _resolver.getEventsForGroup(_group);
    _baseEvents = _deduplicate(fresh);
    _notifyChanges();
    return _baseEvents;
  }

  /// Manually re-syncs data from backend.
  Future<void> manualRefresh(BuildContext context) async {
    await _refreshFromBackend(context);
  }

  Future<void> _refreshFromBackend(BuildContext context) async {
    if (_group.id == Group.createDefaultGroup().id) return;

    final fetchedEvents = await _resolver.getEventsForGroup(_group);
    _baseEvents = _deduplicate(fetchedEvents);

    for (final event in _baseEvents) {
      await syncReminderFor(context, event);
    }

    _notifyChanges();
  }

  /// CRUD operations
  Future<Event> createEvent(BuildContext context, Event event) async {
    final created = await _eventService.createEvent(event);
    _baseEvents = _deduplicate([..._baseEvents, created]);
    await syncReminderFor(context, created);
    _notifyChanges();
    return created;
  }

  Future<Event> updateEvent(BuildContext context, Event event) async {
    await _eventService.updateEvent(event);
    final fresh = await _eventService.getEventById(event.id);
    _baseEvents = _deduplicate(
      _baseEvents.map((e) => e.id == fresh.id ? fresh : e).toList(),
    );
    await syncReminderFor(context, fresh);
    _notifyChanges();
    return fresh;
  }

  Future<void> deleteEvent(String id) async {
    final mongoId = id.contains('-') ? id.split('-').first : id;

    await _eventService.deleteEvent(mongoId);

    final toRemove = _baseEvents
        .where(
          (e) =>
              e.id == id ||
              e.id == mongoId ||
              e.rawRuleId == mongoId ||
              e.rawRuleId == id,
        )
        .toList();

    for (final event in toRemove) {
      await cancelReminderFor(event);
    }

    _baseEvents.removeWhere((e) => toRemove.contains(e));
    _notifyChanges();
  }

  /// Retrieves a single event by ID, with fallback support.
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

  /// Query: Get events for a single calendar day
  List<Event> getEventsForDate(DateTime date) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return _baseEvents
        .where(
          (e) => e.startDate.isBefore(dayEnd) && e.endDate.isAfter(dayStart),
        )
        .toList();
  }

  /// Query: Get events overlapping a visible date range
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

  /// Alias for range-based expansion
  List<Event> getExpandedEvents(DateTimeRange range) =>
      getEventsForRange(range);

  /// Emits new values to listeners when the event list changes
  void _notifyChanges() {
    if (_eventsController.isClosed) {
      debugPrint("⚠️ Tried to notify changes after controller was closed");
      return;
    }

    _groupManagement.currentGroup = _group;

    final now = DateTime.now();
    final visibleRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now.add(const Duration(days: 365)),
    );

    final expanded = getExpandedEvents(visibleRange);

    // Debug recurring expansion
    for (final e in _baseEvents) {
      if (e.recurrenceRule != null) {
        final instances = expandRecurringEventForRange(e, visibleRange);
        // debugPrint('🔁 ${e.title} → ${instances.length} occurrences');
      }
    }

    _eventsController.add(expanded); // ✅ Now only called if not closed
    eventsNotifier.value = List.unmodifiable(expanded);

    onExternalEventUpdate?.call();
    _resolver.updateCache(_group.id, _baseEvents);
  }

  /// Helpers
  List<Event> _deduplicate(List<Event> list) =>
      {for (var e in list) e.id: e}.values.toList();

  bool _overlapsRange(DateTime start, DateTime end, DateTimeRange range) =>
      start.isBefore(range.end) && end.isAfter(range.start);

  /// Clean up resources and unsubscribe from socket events
  void dispose() {
    final socketManager = SocketManager();
    socketManager.off(SocketEvents.created);
    socketManager.off(SocketEvents.updated);
    socketManager.off(SocketEvents.deleted);

    _eventsController.close();
    eventsNotifier.dispose();
  }

  /// Legacy method from older code
  Future<void> removeGroupEvents({required Event event}) =>
      deleteEvent(event.id);

  /// Expose stream to consumers
  Stream<List<Event>> get eventsStream => _eventsController.stream;

  /// Expose raw events
  List<Event> get baseEvents => _baseEvents;
}
