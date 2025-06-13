import 'dart:async';

import 'package:first_project/a-models/group_model/event/event.dart';
import 'package:first_project/a-models/group_model/event/event_group_resolver.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/b-backend/api/socket/socket_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:flutter/material.dart';

class EventDataManager {
  List<Event> _events = [];
  late final Group _group;
  final EventService _eventService;
  final GroupManagement _groupManagement;
  final StreamController<List<Event>> _eventsController =
      StreamController<List<Event>>.broadcast();
  final GroupEventResolver _resolver;

  /// 🔁 Optional callback to notify UI (e.g. force calendar redraw)
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
    _setupSocketListeners(); // 👈 Add this
  }

  void _setupSocketListeners() {
    final socket = SocketManager().socket;

    socket.on('event:created', (data) {
      final newEvent = Event.fromJson(data);
      _events = _deduplicateEvents([..._events, newEvent]);
      _notifyChanges();
    });

    socket.on('event:updated', (data) {
      final updated = Event.fromJson(data);
      _events = _events.map((e) => e.id == updated.id ? updated : e).toList();
      _notifyChanges();
    });

    socket.on('event:deleted', (data) {
      final deletedId = data['id']; // or just `data` if you emit a string
      _events.removeWhere((e) => e.id == deletedId);
      _notifyChanges();
    });
  }

  /// Initializes the manager with initial events and triggers a backend refresh.
  Future<void> _initialize(List<Event> initialEvents) async {
    _events = _deduplicateEvents(initialEvents);
    await _refreshFromBackend(); // Ensures freshest data from server
  }

  void _notifyChanges() {
    _groupManagement.currentGroup = _group;
    _eventsController.add(_events);
    eventsNotifier.value = List.unmodifiable(_events);
    onExternalEventUpdate?.call();
    _resolver.updateCache(_group.id, _events);
  }

  // --- Public API ---
  List<Event> get events => _events;
  Stream<List<Event>> get eventsStream => _eventsController.stream;

  /// Manually force a full re-fetch from the backend
  Future<void> manualRefresh() async => await _refreshFromBackend();

  /// Fetch & update the full list, returns it for inline use
  Future<List<Event>> fetchAllEvents() async {
    final fresh = await _resolver.getEventsForGroup(_group);
    updateEvents(fresh);
    return fresh;
  }

  Future<Event?> fetchEvent(String eventId) =>
      _eventService.getEventById(eventId);

  Future<Event> createEvent(Event event) async {
    try {
      final created = await _eventService.createEvent(event);
      _events = _deduplicateEvents([..._events, created]);
      _notifyChanges();
      return created;
    } catch (e) {
      await manualRefresh();
      rethrow;
    }
  }

  Future<Event> updateEvent(Event event) async {
    try {
      await _eventService.updateEvent(event.id, event);
      final fresh = await _eventService.getEventById(event.id);

      _events = _deduplicateEvents(
        _events.map((e) => e.id == fresh.id ? fresh : e).toList(),
      );

      _notifyChanges();

      return fresh;
    } catch (e) {
      await manualRefresh();
      rethrow;
    }
  }

  void updateEvents(List<Event> newEvents) {
    _events = _deduplicateEvents(newEvents);
    _notifyChanges();
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventService.deleteEvent(eventId);
      _events.removeWhere((e) => e.id == eventId);
      _notifyChanges();
    } catch (e) {
      await manualRefresh();
      rethrow;
    }
  }

  Future<void> removeGroupEvents({required Event event}) =>
      deleteEvent(event.id);

  Future<void> _refreshFromBackend() async {
    if (_group.id == Group.createDefaultGroup().id) return;
    final all = await _resolver.getEventsForGroup(_group);
    _events = _deduplicateEvents(all);
    _notifyChanges();
  }

  List<Event> _deduplicateEvents(List<Event> list) =>
      {for (var e in list) e.id: e}.values.toList();

  List<Event> getEventsForDate(DateTime date) {
    final utcDayStart = DateTime.utc(date.year, date.month, date.day);
    final utcDayEnd = utcDayStart.add(const Duration(days: 1));
    return _events.where((e) {
      final start = e.startDate.toUtc();
      final end = e.endDate.toUtc();
      return start.isBefore(utcDayEnd) && end.isAfter(utcDayStart);
    }).toList();
  }

  void dispose() {
    _eventsController.close();
    eventsNotifier.dispose();
  }
}
