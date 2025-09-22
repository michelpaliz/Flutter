// lib/c-frontend/b-calendar-section/screens/calendar/event_screen_logic/ui/events_in_calendar/event_display_manager/event_display_manager.dart
import 'package:flutter/material.dart';


import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/event/logic/actions/event_actions_manager.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/widgets/event_content_builder.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/event_display_manager/async_loaders/event_future_content.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/event_display_manager/widgets/event_compact_view.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/event_display_manager/widgets/event_details_card.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/event_display_manager/widgets/schedule_card_view.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/event_display_manager/widgets/timeline_strip_widget.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


//  It knows how to build the different event widgets (details card, compact strip, timeline strip, schedule card, async future content). It optionally holds an `EventActionManager` and always needs an `EventContentBuilder` (mainly for colors/content bits). It directly returns Widgets.
class EventDisplayManager {
  EventActionManager? _actionManager;
  final EventContentBuilder _builder;

  EventDisplayManager(
    EventActionManager? actionMgr, {
    required EventContentBuilder builder,
  })  : _actionManager = actionMgr,
        _builder = builder;

  void setEventActionManager(EventActionManager mgr) {
    _actionManager = mgr;
  }

  /// Full details card (used in non-month detailed panes).
  Widget buildEventDetails(
    Event event,
    BuildContext context,
    Color textColor,
    dynamic appointment,
    String userRole,
  ) {
    return EventDetailsCard(
      event: event,
      contextRef: context,
      textColor: textColor,
      appointment: appointment,
      userRole: userRole,
      actionManager: _actionManager,
      colorManager: _builder.colorManager,
    );
  }

  /// Async loader when the appointment needs to fetch extra data.
  Widget buildFutureEventContent(
    Event event,
    Color textColor,
    CalendarAppointmentDetails details,
    String userRole,
  ) {
    return EventFutureContentWidget(
      event: event,
      textColor: textColor,
      details: details,
      userRole: userRole,
      actionManager: _actionManager,
      colorManager: _builder.colorManager,
    );
  }

  /// Compact strip for day/week/agenda (non-month views).
  Widget buildNonMonthViewEvent(
    Event event,
    CalendarAppointmentDetails details,
    Color textColor,
    String userRole,
  ) {
    return EventCompactView(
      event: event,
      details: details,
      textColor: textColor,
      actionManager: _actionManager,
      colorManager: _builder.colorManager,
      userRole: userRole,
    );
  }

  /// Timeline-day compact label.
  Widget buildTimelineDayAppointment(
    Event event,
    CalendarAppointmentDetails details,
    Color textColor,
    String userRole,
  ) {
    return TimelineStripWidget(
      event: event,
      details: details,
      textColor: textColor,
      actionManager: _actionManager,
      colorManager: _builder.colorManager,
      userRole: userRole,
    );
  }

  /// Schedule view card (and timeline-day detailed card).
  Widget buildScheduleViewEvent(
    Event event,
    BuildContext context,
    Color textColor,
    dynamic appointment,
    String userRole,
  ) {
    final cardColor = _builder.colorManager.getColor(event.eventColorIndex);
    return ScheduleCardView(
      event: event,
      contextRef: context,
      textColor: textColor,
      appointment: appointment,
      cardColor: cardColor,
      actionManager: _actionManager,
      userRole: userRole,
    );
  }
}
