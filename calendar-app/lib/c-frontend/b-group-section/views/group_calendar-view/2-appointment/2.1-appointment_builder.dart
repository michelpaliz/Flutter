import 'package:first_project/a-models/model/group_data/event-appointment/event/event.dart';
import 'package:first_project/c-frontend/b-group-section/views/group_calendar-view/3-event/backend/event_data_manager.dart';

import 'package:first_project/c-frontend/b-group-section/views/group_calendar-view/3-event/ui/b-event_display_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarAppointmentBuild {
  final EventDataManager _eventManager;
  final EventDisplayManager _eventDisplayManager;

  CalendarAppointmentBuild(this._eventManager, this._eventDisplayManager);

  // Build for week view appointments
  Widget buildWeekAppointment(CalendarAppointmentDetails details,
      Color textColor, BuildContext context, dynamic appointment) {
    return _eventDisplayManager.buildFutureEventContent(
        appointment.id, textColor, context, appointment);
  }

  // Build for timeline day appointments
  Widget buildTimelineDayAppointment(CalendarAppointmentDetails details,
      Color textColor, BuildContext context, dynamic appointment) {
    return _eventDisplayManager.buildFutureEventContent(
        appointment.id, textColor, context, appointment);
  }

  // Build for timeline week appointments
  Widget buildTimelineWeekAppointment(CalendarAppointmentDetails details,
      Color textColor, BuildContext context, dynamic appointment) {
    return _eventDisplayManager.buildFutureEventContent(
        appointment.id, textColor, context, appointment);
  }

  // Build for timeline month appointments
  Widget buildTimelineMonthAppointment(CalendarAppointmentDetails details,
      Color textColor, BuildContext context, dynamic appointment) {
    return _eventDisplayManager.buildFutureEventContent(
        appointment.id, textColor, context, appointment);
  }

  // Default build method when the view is not explicitly handled
  Widget defaultBuildAppointment(
      CalendarAppointmentDetails details,
      Color textColor,
      BuildContext context,
      String selectedView,
      String userRole) {
    final appointment = details.appointments.first;

    // Check the selected calendar view type
    if (selectedView == CalendarView.month.toString()) {
      return FutureBuilder<Event?>(
        future: _eventManager. fetchEvent(appointment.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator.adaptive();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final Event? event = snapshot.data;
            if (event != null) {
              return _eventDisplayManager.buildEventDetails(
                  event, context, textColor, appointment, userRole);
            } else {
              return Container(
                child: Text(
                  'No events found for this date',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              );
            }
          }
        },
      );
    } else {
      // Handle other calendar views
      return FutureBuilder<Event?>(
        future: _eventManager.fetchEvent(appointment.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final event = snapshot.data;
            if (event != null) {
              return _eventDisplayManager.buildNonMonthViewEvent(
                  event, details, textColor, context);
            } else {
              return Text('No event data found for this appointment');
            }
          }
        },
      );
    }
  }
}
