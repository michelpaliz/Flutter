import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/b-backend/core/event/domain/event_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/bridge/event_display_manager.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarAppointmentBuild {
  final EventDomain _eventManager;
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
