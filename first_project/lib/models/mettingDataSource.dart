import 'dart:ui';

import 'package:first_project/models/event.dart';
import 'package:first_project/utilities/color_manager.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class DataSource extends CalendarDataSource<Event> {
  DataSource(List<Event>? source) {
    appointments = source;
  }
  @override
  DateTime getStartTime(int index) {
    return appointments![index].startDate;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endDate;
  }

  @override
  String getSubject(int index) {
    return appointments![index].title;
  }

  @override
  Color getColor(int index) {
    return ColorManager().getColor(appointments![index].eventColorIndex);
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].allDay;
  }

  @override
  Event convertAppointmentToObject(Event customData, Appointment appointment) {
    return Event(
      id: customData.id,
      startDate: appointment.startTime,
      endDate: appointment.endTime,
      title: appointment.subject,
      groupId: customData.groupId,
      done: customData.done,
      recurrenceRule: customData.recurrenceRule,
      localization: customData.localization,
      allDay: appointment.isAllDay,
      note: customData.note,
      description: customData.description,
      eventColorIndex: customData.eventColorIndex,
    );
  }

  set events(List<Event>? newEvents) {
    appointments = newEvents;
    notifyListeners(CalendarDataSourceAction.reset, newEvents!);
  }
}
