import 'package:first_project/c-frontend/c-event-section/utils/event/color_manager.dart';
import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  final List<Event> events;

  EventDataSource(this.events);

  @override
  List<dynamic> get appointments => events;

  @override
  DateTime getStartTime(int index) {
    return events[index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return events[index].endDate;
  }

  @override
  String getSubject(int index) {
    return events[index].title;
  }

  @override
  String? getLocation(int index) {
    return events[index].localization;
  }

  String? getDescription(int index) {
    return events[index].description;
  }

  String? getRecurrenceRule(int index) {
    final recurrenceRule = events[index].recurrenceRule;
    return recurrenceRule?.toString();
  }

  @override
  Color getColor(int index) {
    // Use the eventColorIndex to determine the color for the appointment
    // You can define a logic here to map eventColorIndex to a specific color
    // For example, you can use a list of predefined colors and access them by index
    final List<Color> predefinedColors = ColorManager.eventColors;

    final int colorIndex = events[index].eventColorIndex;

    // Ensure the colorIndex is within the bounds of the predefinedColors list
    if (colorIndex >= 0 && colorIndex < predefinedColors.length) {
      return predefinedColors[colorIndex];
    } else {
      // Return a default color if the index is out of bounds
      return Colors.grey;
    }
  }

  @override
  bool isAllDay(int index) {
    return events[index].allDay;
  }

  bool isDone(int index) {
    return events[index].done;
  }

  // Implement other necessary methods as needed
}
