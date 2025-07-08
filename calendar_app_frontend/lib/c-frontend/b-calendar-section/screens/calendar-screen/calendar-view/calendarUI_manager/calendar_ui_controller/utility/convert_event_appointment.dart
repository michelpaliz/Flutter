// lib/utils/event_to_appointment.dart
import 'dart:convert';

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Appointment convertEventToAppointment(Event event) {
  return Appointment(
    id: event.id,
    startTime: event.startDate,
    endTime: event.endDate,
    subject: event.title,
    location: event.localization,
    notes: jsonEncode({
      ...event.toJson(),
      'rawRuleId': event.rawRuleId ?? event.id,
    }),
    isAllDay: event.allDay,
    color: ColorManager().getColor(event.eventColorIndex),
    recurrenceRule: event.rule,
  );
}
