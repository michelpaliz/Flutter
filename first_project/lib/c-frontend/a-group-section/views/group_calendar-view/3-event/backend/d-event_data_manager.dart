import 'package:first_project/a-models/event.dart';
import 'package:first_project/b-backend/database_conection/node_services/event_services.dart';
import 'package:first_project/a-models/group.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
//  It can be used by the EventActionManager for event-related logic, but it focuses on data fetching, updating, and syncing with the backend.

//  Primary Purpose

//     EventDataManager:
//         This class is responsible for managing the event data itself, including syncing it with the backend (e.g., updating or removing events from the database), maintaining the local list of events, and providing methods to fetch, update, or delete events.
//         It does not handle any UI or interaction logic directly. Instead, it focuses on data handling and backend communication.

// 2. Responsibilities
//     EventDataManager:
//         Manages the local list of events and synchronizes it with the backend (_updateCalendarDataSource, removeGroupEvents, updateEvent).
//         Provides methods to fetch and update event data, including communication with services like EventService (fetchEvent, updateEvent).
//         Focuses on data operations, such as retrieving events for a specific date (getEventsForDate) or calculating differences between dates (calculateDaysBetweenDates).

// 3. Interfacing with Other Components

//     EventDataManager:
//         Primarily interacts with the backend services like EventService for CRUD operations on events.
//         Interfaces with GroupManagement to maintain consistency between the events and the associated group.


class EventDataManager {
  late List<Event> _events;
  late Group _group;
  final EventService _eventService;
  final GroupManagement _groupManagement;

  EventDataManager(
    List<Event> events, {
    required Group group,
    required EventService eventService,
    required GroupManagement groupManagement,
  })  : _group = group,
        _eventService = eventService,
        _groupManagement = groupManagement {
    _events = _group.calendar.events;
  }

  // Update an event in the data source
  Future<void> updateEvent(Event event) async {
    try {
      // Update the event using the service
      Event updatedEvent = await _eventService.updateEvent(event.id, event);
      int index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = updatedEvent;
        _updateCalendarDataSource();
      }
    } catch (error) {
      print('Error updating event: $error');
    }
  }

  // Remove group events from Firestore and locally
  Future<void> removeGroupEvents({required Event event}) async {
    await _eventService.deleteEvent(event.id);
    _events.removeWhere((e) => e.id == event.id);
    _updateCalendarDataSource();
  }

  // Method to reload group data and update events
  Future<void> reloadData() async {
    Group? group = await _groupManagement.groupService.getGroupById(_group.id);
    _group = group;
    _events = group.calendar.events;
    _updateCalendarDataSource();
    }

  // Get events for a specific date
  List<Event> getEventsForDate(DateTime date) {
    final DateTime utcDate = DateTime.utc(date.year, date.month, date.day);
    return _events.where((event) {
      final DateTime eventStartDate = event.startDate.toUtc();
      final DateTime eventEndDate = event.endDate.toUtc();
      return eventStartDate.isBefore(utcDate.add(Duration(days: 1))) &&
          eventEndDate.isAfter(utcDate);
    }).toList();
  }

  // Helper to update the local calendar's data source
  void _updateCalendarDataSource() {
    _group.calendar.events = _events;
    _groupManagement.currentGroup = _group;
  }

  // Fetch event with EventDataManager
  Future<Event?> fetchEvent(String eventId) {
    return _eventService.getEventById(eventId);
  }
}