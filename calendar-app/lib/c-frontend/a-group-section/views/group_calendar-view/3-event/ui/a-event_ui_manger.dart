import 'package:first_project/a-models/event.dart';
import 'package:first_project/a-models/group.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/3-event/ui/c-event_actions_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/3-event/ui/event_content_builder.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/3-event/ui/b-event_display_manager.dart';
import 'package:first_project/utilities/color_manager.dart';
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

  // Builds future event content, delegating to the EventDisplayManager
  Widget buildFutureEventContent(
      String eventId,
      Color textColor,
      BuildContext context,
      dynamic appointment,
      Future<Event?> Function(String) fetchEvent) {
    // Delegates to EventDisplayManager, no need to pass fetchEvent because it is handled internally
    return displayManager.buildFutureEventContent(
        eventId, textColor, context, appointment);
  }

  // Builds the add event button, delegating to EventActionManager
  Widget buildAddEventButton(
      BuildContext context, Group group, Function(Group) updateGroup) {
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
