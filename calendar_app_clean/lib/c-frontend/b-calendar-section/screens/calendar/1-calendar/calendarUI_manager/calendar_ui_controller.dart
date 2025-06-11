import 'dart:async';

import 'package:first_project/a-models/group_model/event/event.dart';
import 'package:first_project/a-models/group_model/event/event_data_source.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/1-calendar/calendarUI_manager/calendar_mont_cell.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/2-appointment/appointment_builder.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/widgets/event_display_manager.dart';
import 'package:first_project/d-stateManagement/event/event_data_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'calendar_styles.dart';

class CalendarUIController {
  final CalendarController _controller = CalendarController();
  final EventDisplayManager _eventDisplayManager;
  final EventDataManager _eventDataManager;
  final GroupManagement groupManagement;
  final String userRole;

  late final EventDataSource _eventDataSource;
  final ValueNotifier<int> calendarRefreshKey = ValueNotifier(0);
  Timer? _refreshDebounce;

  /// 👇 Public getter for external access if needed
  EventDataManager get eventDataManager => _eventDataManager;

  /// 👇 Holds events for the selected day
  final ValueNotifier<List<Event>> dailyEvents = ValueNotifier([]);

  /// 👇 Holds all current events (used by monthCellBuilder)
  final ValueNotifier<List<Event>> allEvents = ValueNotifier([]);

  late final CalendarAppointmentBuild _calendarAppointmentBuilder;
  CalendarView _selectedView = CalendarView.month;
  DateTime? _selectedDate;

  CalendarUIController({
    required EventDataManager eventDataManager,
    required EventDisplayManager eventDisplayManager,
    required this.groupManagement,
    required this.userRole,
  })  : _eventDataManager = eventDataManager,
        _eventDisplayManager = eventDisplayManager {
    _calendarAppointmentBuilder = CalendarAppointmentBuild(
      _eventDataManager,
      _eventDisplayManager,
    );

    _eventDataSource = EventDataSource(_eventDataManager.events);

    _eventDataManager.eventsStream.listen((updatedEvents) {
      debugPrint(
        "📅 [CalendarUI] Received ${updatedEvents.length} events from stream",
      );
      _eventDataSource.updateEvents(updatedEvents);

      // 👇 Update allEvents for month cell UI
      allEvents.value = List<Event>.from(updatedEvents);

      if (_selectedDate != null) {
        dailyEvents.value = _eventDataManager.getEventsForDate(_selectedDate!);
      }
    });

    _eventDataManager.onExternalEventUpdate = () {
      // notifyCalendarToRedraw();
      triggerCalendarHardRefresh();
    };
  }

  void triggerCalendarHardRefresh() {
    debugPrint("🔁 Triggering calendar hard refresh...");
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 100), () {
      calendarRefreshKey.value++;
    });
  }

  void notifyCalendarToRedraw() {
    final current = _controller.displayDate;
    if (current != null) {
      _controller.displayDate = current.add(const Duration(days: 1));
      Future.delayed(const Duration(milliseconds: 10), () {
        _controller.displayDate = current;
      });
    }
  }

  Future<void> reloadGroup({required String groupId}) async {
    final updatedGroup =
        await groupManagement.groupService.getGroupById(groupId);
    groupManagement.currentGroup = updatedGroup;
    debugPrint("📦 Group fetched: ${updatedGroup.id}");
  }

  void dispose() {
    _eventDataManager.dispose();
    dailyEvents.dispose();
    allEvents.dispose();
    calendarRefreshKey.dispose();
  }

  Widget buildCalendar(BuildContext context, {double? height, double? width}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = getTextColor(context);
    final backgroundColor = getBackgroundColor(context).withOpacity(0.8);
    final fontSize = (width ?? MediaQuery.of(context).size.width) * 0.035;

    return ValueListenableBuilder<int>(
      valueListenable: calendarRefreshKey,
      builder: (context, refreshKey, _) {
        return Container(
          height: height,
          width: width,
          decoration: buildContainerDecoration(backgroundColor),
          child: SfCalendar(
            key: ValueKey(refreshKey),
            controller: _controller,
            dataSource: _eventDataSource,
            view: _selectedView,
            allowedViews: CalendarView.values,
            onViewChanged: (_) => _selectedView = _controller.view!,
            onSelectionChanged: (details) {
              if (details.date != null) {
                _selectedDate = details.date!;
                _controller.selectedDate = _selectedDate;
                dailyEvents.value =
                    _eventDataManager.getEventsForDate(_selectedDate!);
              }
            },

            /// 👇 Use ValueListenableBuilder for updated events
            monthCellBuilder: (context, details) => buildMonthCell(
              context: context,
              details: details,
              selectedDate: _selectedDate,
              isDarkMode: isDarkMode,
              events: _eventDataManager
                  .events, // now up-to-date thanks to refreshKey
            ),

            appointmentBuilder: (context, details) {
              try {
                final appt = details.appointments.first;
                if (appt is! Event) {
                  return const Text(
                    'Invalid Event',
                    style: TextStyle(color: Colors.red),
                  );
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
                return const Text(
                  'Error rendering',
                  style: TextStyle(color: Colors.red),
                );
              }
            },
            selectionDecoration: const BoxDecoration(color: Colors.transparent),
            showNavigationArrow: true,
            showDatePickerButton: true,
            firstDayOfWeek: DateTime.monday,
            initialSelectedDate: DateTime.now(),
            headerStyle: buildHeaderStyle(fontSize, textColor),
            viewHeaderStyle:
                buildViewHeaderStyle(fontSize, textColor, isDarkMode),
            scheduleViewSettings:
                buildScheduleSettings(fontSize, backgroundColor),
            monthViewSettings: buildMonthSettings(),
          ),
        ).animate().fadeIn(duration: 500.ms);
      },
    );
  }
}
