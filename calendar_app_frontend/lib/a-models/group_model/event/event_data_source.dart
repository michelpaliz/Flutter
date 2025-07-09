import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  List<Event> _events;

  EventDataSource(List<Event> events) : _events = events {
    appointments = events;
  }

  void updateEvents(List<Event> newEvents) {
    _events = List<Event>.from(newEvents);
    appointments = List<Event>.from(newEvents);
    notifyListeners(CalendarDataSourceAction.reset, _events);
  }

  @override
  DateTime getStartTime(int index) => _events[index].startDate;

  @override
  DateTime getEndTime(int index) => _events[index].endDate;

  @override
  String getSubject(int index) => _events[index].title;

  @override
  String? getLocation(int index) => _events[index].localization;
  @override
  Object? getId(int index) => _events[index].id;
  @override
  Object? getRecurrenceId(int index) => _events[index].recurrenceRule?.id;

  @override
  String? getRecurrenceRule(int index) {
    final rule = _events[index].recurrenceRule;

    debugPrint('🧪 recurrenceRule runtimeType: ${rule.runtimeType}');
    debugPrint('🧪 recurrenceRule content: $rule');

    final stringValue = rule?.toString();
    final match = RegExp(r'RRULE:(.*)').firstMatch(stringValue ?? '');
    final cleanedRule = match?.group(1);

    if (cleanedRule == null) {
      debugPrint('⚠️ Malformed recurrence rule string: $stringValue');
      return null;
    }

    return cleanedRule;
  }

  // @override
  // String? getRecurrenceRule(int index) {
  //   final event = _events[index];
  //   final rule = event.recurrenceRule;

  //   if (rule == null) {
  //     debugPrint('⚠️ No recurrence rule for "${event.title}"');
  //     return null;
  //   }

  //   final rrule = rule.toRRuleString(event.startDate, includeDtStart: false);
  //   final cleaned = rrule.replaceFirst('RRULE:', '');

  //   debugPrint('📅 Final clean RRULE for "${event.title}": $cleaned');
  //   return cleaned;
  // }

  @override
  Color getColor(int index) {
    final colorIndex = _events[index].eventColorIndex;
    final predefinedColors = ColorManager.eventColors;
    return (colorIndex >= 0 && colorIndex < predefinedColors.length)
        ? predefinedColors[colorIndex]
        : Colors.grey;
  }

  @override
  bool isAllDay(int index) => _events[index].allDay;

  bool isDone(int index) => _events[index].isDone;

  /// 👇 **These two are crucial for calendar views to work correctly**
  int get count => _events.length;

  Object? getAppointment(int index) => _events[index];
}
