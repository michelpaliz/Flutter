import 'dart:async';

import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/c-frontend/b-group-section/utils/network/safe_api_call.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';

class EventDataManager {
  List<Event> _events = [];
  late final Group _group;
  final EventService _eventService;
  final GroupManagement _groupManagement;
  final StreamController<List<Event>> _eventsController =
      StreamController<List<Event>>.broadcast();

  EventDataManager(
    List<Event> initialEvents, {
    required Group group,
    required EventService eventService,
    required GroupManagement groupManagement,
  })  : _group = group,
        _eventService = eventService,
        _groupManagement = groupManagement {
    _initialize(initialEvents);
  }

  // --- Public API ---
  List<Event> get events => _events;
  Stream<List<Event>> get eventsStream => _eventsController.stream;

  // --- Initialization ---
  Future<void> _initialize(List<Event> initialEvents) async {
    _events = _deduplicateEvents([...initialEvents, ..._group.calendar.events]);
    await safeApiCall(() => _refreshFromBackend()); //the user must have a token
  }

  // Add this method back (unchanged from original)
  Future<Event?> fetchEvent(String eventId) {
    return _eventService.getEventById(eventId);
  }

  // --- Hybrid Operations ---
  Future<void> manualRefresh() async => await _refreshFromBackend();

  Future<Event> createEvent(Event event) async {
    try {
      final createdEvent = await _eventService.createEvent(event);
      _events = _deduplicateEvents([..._events, createdEvent]);
      _notifyChanges();
      return createdEvent;
    } catch (e) {
      await _refreshFromBackend(); // Fallback to sync
      rethrow;
    }
  }

  Future<Event> updateEvent(Event event) async {
    try {
      final updatedEvent = await _eventService.updateEvent(event.id, event);
      _replaceInList(updatedEvent);
      return updatedEvent;
    } catch (e) {
      await _refreshFromBackend();
      rethrow;
    }
  }

  // Add this to your EventDataManager class
  void updateEvents(List<Event> newEvents) {
    _events = _deduplicateEvents(newEvents);
    _notifyChanges(); // This will update both the stream and group management
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventService.deleteEvent(eventId);
      _events.removeWhere((e) => e.id == eventId);
      _notifyChanges();
    } catch (e) {
      await _refreshFromBackend();
      rethrow;
    }
  }

  // --- Data Helpers ---
  Future<void> _refreshFromBackend() async {
    // ←——— if we're still on the dummy group, do nothing
    if (_group.id == Group.createDefaultGroup().id) return;

    try {
      _events = _deduplicateEvents(
        await _eventService.getEventsByGroupId(_group.id),
      );
      _notifyChanges();
    } catch (e) {
      _eventsController.addError(e);
      rethrow;
    }
  }

  void _replaceInList(Event updatedEvent) {
    final index = _events.indexWhere((e) => e.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      _notifyChanges();
    }
  }

  List<Event> _deduplicateEvents(List<Event> events) {
    return events
        .fold<Map<String, Event>>({}, (map, event) {
          map[event.id] = event;
          return map;
        })
        .values
        .toList();
  }

  Future<void> removeGroupEvents({required Event event}) async {
    await deleteEvent(event.id);
  }

  void _notifyChanges() {
    _group.calendar.events = _events;
    _groupManagement.currentGroup = _group;
    _eventsController.add(_events);
  }

  // --- Cleanup ---
  void dispose() => _eventsController.close();

  // --- Date Filtering ---
  List<Event> getEventsForDate(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return _events.where((event) {
      final start = event.startDate.toUtc();
      final end = event.endDate.toUtc();
      return start.isBefore(utcDate.add(const Duration(days: 1))) &&
          end.isAfter(utcDate);
    }).toList();
  }
}
