import 'package:first_project/models/event.dart';

class EventDateRange {
  final DateTime startDate;
  final DateTime endDate;
  final List<Event> events;

  EventDateRange({
    required this.startDate,
    required this.endDate,
    required this.events,
  });
}


// Preprocess the event data to create date ranges
List<EventDateRange> preprocessEventData(List<Event> events) {
  final List<EventDateRange> dateRanges = [];
  if (events.isEmpty) {
    return dateRanges;
  }

  // Sort events by start date
  events.sort((a, b) => a.startDate.compareTo(b.startDate));

  DateTime currentStartDate = events.first.startDate;
  DateTime currentEndDate = events.first.endDate;
  List<Event> currentEvents = [events.first];

  for (int i = 1; i < events.length; i++) {
    final event = events[i];
    if (event.startDate.isAfter(currentEndDate.add(Duration(days: 1)))) {
      // Event is not consecutive, start a new date range
      dateRanges.add(EventDateRange(
        startDate: currentStartDate,
        endDate: currentEndDate,
        events: currentEvents,
      ));

      // Start a new date range
      currentStartDate = event.startDate;
      currentEndDate = event.endDate;
      currentEvents = [event];
    } else {
      // Event is consecutive, expand the date range
      currentEndDate = event.endDate;
      currentEvents.add(event);
    }
  }

  // Add the last date range
  dateRanges.add(EventDateRange(
    startDate: currentStartDate,
    endDate: currentEndDate,
    events: currentEvents,
  ));

  return dateRanges;
}