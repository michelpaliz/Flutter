import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/event_appointment/event/event_data_source.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/1-calendar/calendarUI_manager/calendar_mont_cell.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/2-appointment/appointment_builder.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/event_list_ui/widgets/event_display_manager.dart';
import 'package:first_project/d-stateManagement/event/event_data_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
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
  late final EventDataSource _eventDataSource;

  late CalendarAppointmentBuild _calendarAppointmentBuilder;
  CalendarView _selectedView = CalendarView.month;
  DateTime? _selectedDate;

  /// ✅ Constructor now expects shared EventDataManager
  CalendarUIManager({
    required EventDataManager eventDataManager,
    required EventDisplayManager eventDisplayManager,
    required this.userRole,
    required this.groupManagement,
  })  : _eventDisplayManager = eventDisplayManager,
        _eventDataManager = eventDataManager {
    _calendarAppointmentBuilder = CalendarAppointmentBuild(
      _eventDataManager,
      _eventDisplayManager,
    );

    // ✅ Initialize the data source from EventDataManager
    _eventDataSource = EventDataSource(_eventDataManager.events);

    // ✅ Listen to the shared event stream
    _eventDataManager.eventsStream.listen((updatedEvents) {
      _eventDataSource.updateEvents(updatedEvents);
    });
  }

  EventDataManager get eventDataManager => _eventDataManager;

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

    final List<Event> currentEvents =
        groupManagement.currentGroup?.calendar.events ?? [];

    final calendar = SfCalendar(
      controller: _controller,
      dataSource: _eventDataSource,
      view: _selectedView,
      allowedViews: CalendarView.values,

      // ✅ Set height of appointments in day/week/workWeek views
      // timeSlotViewSettings: const TimeSlotViewSettings(
      //   minimumAppointmentDuration: Duration(minutes: 150), // or 90, 120 etc.
      //   timeIntervalHeight: 120, // increase this for more vertical spa
      //   timeInterval: Duration(minutes: 30),
      // ),

      onViewChanged: (_) => _selectedView = _controller.view!,
      onSelectionChanged: (details) {
        if (details.date != null) {
          _selectedDate = details.date!;
          _controller.selectedDate = _selectedDate;
          _eventDataManager.getEventsForDate(_selectedDate!);
        }
      },

      // ✅ Custom month cell builder
      monthCellBuilder: (context, details) => buildMonthCell(
        context: context,
        details: details,
        selectedDate: _selectedDate,
        isDarkMode: isDarkMode,
        events: currentEvents,
      ),

      // ✅ Custom appointment rendering
      appointmentBuilder: (context, details) {
        try {
          final dynamic appointment = details.appointments.first;
          if (appointment is! Event) {
            return const Text('Invalid Event',
                style: TextStyle(color: Colors.red));
          }

          return _calendarAppointmentBuilder
              .defaultBuildAppointment(
                details,
                textColor,
                context,
                _selectedView.toString(),
                userRole,
              )
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

      selectionDecoration: const BoxDecoration(color: Colors.transparent),
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
