import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';

List<Event> filterEventsForDay(List<Event> events, DateTime selectedDay) {
  final dayStart = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
  return events.where((event) {
    return event.startDate.year == dayStart.year &&
        event.startDate.month == dayStart.month &&
        event.startDate.day == dayStart.day;
  }).toList();
}
