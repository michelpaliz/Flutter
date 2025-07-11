import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar/event_screen_logic/ui/events_in_calendar/event_display_manager/event_display_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarAppointmentBuild {
  final EventDataManager _eventManager;
  final EventDisplayManager _eventDisplayManager;

  CalendarAppointmentBuild(this._eventManager, this._eventDisplayManager);

  // Week view
  Widget buildWeekAppointment(
    CalendarAppointmentDetails details,
    Color textColor,
    Event event,
    String userRole,
  ) {
    return _eventDisplayManager.buildNonMonthViewEvent(
      event,
      details,
      textColor,
      userRole,
    );
  }

  // Timeline Day view
  Widget buildTimelineDayAppointment(
    CalendarAppointmentDetails details,
    Color textColor,
    Event event,
    String userRole,
  ) {
    return _eventDisplayManager.buildTimelineDayAppointment(
      event,
      details,
      textColor,
      userRole,
    );
  }

  // Timeline Week view
  Widget buildTimelineWeekAppointment(
    CalendarAppointmentDetails details,
    Color textColor,
    Event event,
    String userRole,
  ) {
    return _eventDisplayManager.buildTimelineDayAppointment(
      event,
      details,
      textColor,
      userRole,
    );
  }

  // Timeline Month view
  Widget buildTimelineMonthAppointment(
    CalendarAppointmentDetails details,
    Color textColor,
    Event event,
    String userRole,
  ) {
    return _eventDisplayManager.buildTimelineDayAppointment(
      event,
      details,
      textColor,
      userRole,
    );
  }

  // Schedule view
  Widget buildScheduleAppointment(
    CalendarAppointmentDetails details,
    Color textColor,
    BuildContext context,
    Event event,
    String userRole,
    Color cardColor,
  ) {
    return _eventDisplayManager.buildScheduleViewEvent(
      event,
      context,
      textColor,
      details.appointments.first,
      userRole,
    );
  }

  Widget defaultBuildAppointment(
    CalendarAppointmentDetails details,
    Color textColor,
    BuildContext context,
    String selectedView,
    String userRole,
  ) {
    final appointment = details.appointments.first;

    // If appointment is already an Event instance, render it directly
    if (appointment is Event) {
      return _eventDisplayManager.buildEventDetails(
        appointment,
        context,
        textColor,
        appointment,
        userRole,
      );
    }

    // Fallback if it's not an Event (unlikely case)
    return Text(
      'Unknown appointment type',
      style: TextStyle(fontSize: 16, color: textColor),
    );
  }
}
