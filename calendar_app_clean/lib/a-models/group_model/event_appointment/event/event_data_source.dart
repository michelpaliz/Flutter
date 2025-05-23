import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  List<Event> _events;

  EventDataSource(List<Event> events) : _events = events {
    appointments = events; // Initialize appointments
  }

  void updateEvents(List<Event> newEvents) {
    _events = newEvents;
    appointments = newEvents;
    notifyListeners(CalendarDataSourceAction.reset, <Event>[]);
  }

  @override
  DateTime getStartTime(int index) => _events[index].startDate;

  @override
  DateTime getEndTime(int index) => _events[index].endDate;

  @override
  String getSubject(int index) => _events[index].title;

  @override
  String? getLocation(int index) => _events[index].localization;

  String? getDescription(int index) => _events[index].description;

  String? getRecurrenceRule(int index) =>
      _events[index].recurrenceRule?.toString();

  @override
  Color getColor(int index) {
    final List<Color> predefinedColors = ColorManager.eventColors;
    final int colorIndex = _events[index].eventColorIndex;

    return (colorIndex >= 0 && colorIndex < predefinedColors.length)
        ? predefinedColors[colorIndex]
        : Colors.grey;
  }

  @override
  bool isAllDay(int index) => _events[index].allDay;

  bool isDone(int index) => _events[index].isDone;
}
