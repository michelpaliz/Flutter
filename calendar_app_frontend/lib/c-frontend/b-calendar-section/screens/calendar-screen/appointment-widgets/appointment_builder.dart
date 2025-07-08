import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/event-view/ui/event_list_ui/calendar_views_ui/event_display_manager/event_display_manager.dart';
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
    final appointment = details.appointments
        .first; //important here fetches the real appointment's id for the repetitive events

    // Try extracting the fallback ID (original ID for recurring instances)
    // `final fallbackId = appointment is Event ? appointment.rawRuleId : null;`

    return FutureBuilder<Event?>(
      future: _eventManager.fetchEvent(appointment.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator.adaptive();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data != null) {
          return _eventDisplayManager.buildEventDetails(
            snapshot.data!,
            context,
            textColor,
            appointment,
            userRole,
          );
        } else {
          return Text(
            'No events found for this date',
            style: TextStyle(fontSize: 16, color: textColor),
          );
        }
      },
    );
  }
}
