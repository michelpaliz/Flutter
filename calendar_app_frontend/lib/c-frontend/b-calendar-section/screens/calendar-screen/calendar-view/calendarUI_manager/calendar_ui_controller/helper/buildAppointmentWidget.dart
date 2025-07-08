import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/appointment-widgets/appointment_builder.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Widget buildAppointmentWidget({
  required CalendarAppointmentDetails details,
  required CalendarView view,
  required Color textColor,
  required BuildContext context,
  required CalendarAppointmentBuild builder,
  required EventDataManager manager,
  required String userRole,
}) {
  final appt = details.appointments.first;

  if (appt is! Event) {
    return const Text('❌ Invalid Event');
  }

  final event = appt;

  try {
    final cardColor = ColorManager().getColor(event.eventColorIndex);

    switch (view) {
      case CalendarView.schedule:
        return builder.buildScheduleAppointment(
          details,
          textColor,
          context,
          event,
          userRole,
          cardColor,
        );
      case CalendarView.week:
      case CalendarView.workWeek:
      case CalendarView.day:
        return builder.buildWeekAppointment(
            details, textColor, event, userRole);
      case CalendarView.timelineDay:
        return builder.buildTimelineDayAppointment(
            details, textColor, event, userRole);
      case CalendarView.timelineWeek:
        return builder.buildTimelineWeekAppointment(
            details, textColor, event, userRole);
      case CalendarView.timelineMonth:
        return builder.buildTimelineMonthAppointment(
            details, textColor, event, userRole);
      default:
        return builder.defaultBuildAppointment(
          details,
          textColor,
          context,
          view.toString(),
          userRole,
        );
    }
  } catch (e, stack) {
    debugPrint('❌ Error building event widget: $e');
    print('❌ Error building event widget: $e');
    debugPrintStack(stackTrace: stack);
    return const Text('❌ Failed to render Event');
  }
}
