import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/c-frontend/b-group-section/screens/calendar/3-event/actions/event_actions_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/calendar/3-event/ui/event_list_ui/widgets/event_content_builder.dart';
import 'package:first_project/c-frontend/b-group-section/screens/calendar/3-event/ui/event_list_ui/widgets/event_display_manager.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventUIManager {
  final ColorManager colorManager;
  final EventContentBuilder contentBuilder;
  final EventActionManager actionManager;
  final EventDisplayManager displayManager;

  EventUIManager({
    required this.colorManager,
    required this.contentBuilder,
    required this.actionManager,
    required this.displayManager,
  });

  // Delegates the responsibility to sub-managers or builders
  Widget buildEventDetails(Event event, BuildContext context, Color textColor,
      dynamic appointment, String userRole) {
    // Delegates to EventDisplayManager
    return displayManager.buildEventDetails(
        event, context, textColor, appointment, userRole);
  }

  Widget buildFutureEventContent(
    String eventId,
    Color textColor,
    BuildContext context,
    dynamic appointment,
  ) =>
      displayManager.buildFutureEventContent(
          eventId, textColor, context, appointment);

  // Builds the add event button, delegating to EventActionManager
  Widget buildAddEventButton(BuildContext context, Group group) {
    // Delegates to EventActionManager
    return actionManager.buildAddEventButton(context, group);
  }

  // Builds non-month-view events, delegating to the EventDisplayManager
  Widget buildNonMonthViewEvent(Event event, CalendarAppointmentDetails details,
      Color textColor, BuildContext context) {
    // Delegates to EventDisplayManager
    return displayManager.buildNonMonthViewEvent(
        event, details, textColor, context);
  }
}
