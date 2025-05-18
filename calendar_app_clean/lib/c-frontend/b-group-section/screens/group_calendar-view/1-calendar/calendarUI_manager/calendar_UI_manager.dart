import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/event_appointment/event/event_data_source.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/1-calendar/calendarUI_manager/calendar_mont_cell.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/2-appointment/2.1-appointment_builder.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/b-event_display_manager.dart';
import 'package:first_project/d-stateManagement/event_data_manager.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'calendar_styles.dart';

class CalendarUIManager {
  final CalendarController _controller = CalendarController();
  final EventDisplayManager _eventDisplayManager;
  final EventDataManager _eventDataManager;
  final String userRole;
  final GroupManagement groupManagement;

  late CalendarAppointmentBuild _calendarAppointmentBuilder;
  CalendarView _selectedView = CalendarView.month;
  DateTime? _selectedDate;

  CalendarUIManager({
    required Group group,
    required EventService eventService,
    required EventDisplayManager eventDisplayManager,
    required this.userRole,
    required this.groupManagement,
  })  : _eventDisplayManager = eventDisplayManager,
        _eventDataManager = EventDataManager(
          group.calendar.events,
          group: group,
          eventService: eventService,
          groupManagement: groupManagement,
        ) {
    _calendarAppointmentBuilder = CalendarAppointmentBuild(
      _eventDataManager,
      _eventDisplayManager,
    );
  }

  EventDataManager get eventDataManager => _eventDataManager;

  /// ✅ Call this to reload the group and update the event list
  Future<void> reloadGroup({required String groupId}) async {
    final updatedGroup =
        await groupManagement.groupService.getGroupById(groupId);
    groupManagement.currentGroup = updatedGroup;
    debugPrint("📦 Group fetched: ${updatedGroup.id}");
  }


  Widget buildCalendar(BuildContext context, {double? height, double? width}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = getTextColor(context);
    final backgroundColor = getBackgroundColor(context).withOpacity(0.8);
    final fontSize = (width ?? MediaQuery.of(context).size.width) * 0.035;

    // ✅ Always get fresh events from the current group
    final List<Event> currentEvents =
        groupManagement.currentGroup?.calendar.events ?? [];

    final calendar = SfCalendar(
      controller: _controller,
      dataSource: EventDataSource(currentEvents),
      view: _selectedView,
      allowedViews: CalendarView.values,
      onViewChanged: (_) => _selectedView = _controller.view!,
      onSelectionChanged: (details) {
        if (details.date != null) {
          _selectedDate = details.date!;
          _controller.selectedDate = _selectedDate;
          _eventDataManager.getEventsForDate(_selectedDate!);
        }
      },
      monthCellBuilder: (context, details) => buildMonthCell(
        context: context,
        details: details,
        selectedDate: _selectedDate,
        isDarkMode: isDarkMode,
        events: currentEvents,
      ),
      appointmentBuilder: (context, details) {
        try {
          final dynamic appointment = details.appointments.first;
          if (appointment is! Event) {
            return const Text('Invalid Event',
                style: TextStyle(color: Colors.red));
          }

          return _calendarAppointmentBuilder
              .defaultBuildAppointment(details, textColor, context,
                  _selectedView.toString(), userRole)
              .animate()
              .fadeIn(duration: 300.ms)
              .scale();
        } catch (e, stack) {
          debugPrint('❌ Error in appointmentBuilder: $e');
          debugPrintStack(stackTrace: stack);
          return const Text('Error rendering',
              style: TextStyle(color: Colors.red));
        }
      },
      selectionDecoration: BoxDecoration(color: Colors.transparent),
      showNavigationArrow: true,
      showDatePickerButton: true,
      firstDayOfWeek: DateTime.monday,
      initialSelectedDate: DateTime.now(),
      headerStyle: buildHeaderStyle(fontSize, textColor),
      viewHeaderStyle: buildViewHeaderStyle(fontSize, textColor, isDarkMode),
      scheduleViewSettings: buildScheduleSettings(fontSize, backgroundColor),
      monthViewSettings: buildMonthSettings(),
    );

    return Container(
      height: height,
      width: width,
      decoration: buildContainerDecoration(backgroundColor),
      child: calendar,
    ).animate().fadeIn(duration: 500.ms);
  }
}
