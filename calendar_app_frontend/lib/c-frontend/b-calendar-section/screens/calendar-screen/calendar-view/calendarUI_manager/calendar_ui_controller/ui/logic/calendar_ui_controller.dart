import 'dart:async';

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/event/event_data_source.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/appointment-widgets/appointment_builder.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/calendar-view/calendarUI_manager/calendar_ui_controller/ui/build/calendar_ui_build.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/event-view/ui/event_list_ui/calendar_views_ui/event_display_manager/event_display_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarUIController {
  final CalendarController _controller = CalendarController();
  final EventDisplayManager _eventDisplayManager;
  final EventDataManager _eventDataManager;
  final GroupManagement groupManagement;
  final String userRole;

  late final EventDataSource _eventDataSource;
  final ValueNotifier<int> calendarRefreshKey = ValueNotifier(0);
  Timer? _refreshDebounce;

  EventDataManager get eventDataManager => _eventDataManager;

  final ValueNotifier<List<Event>> dailyEvents = ValueNotifier([]);
  final ValueNotifier<List<Event>> allEvents = ValueNotifier([]);

  final ValueNotifier<EventDataSource> calendarDataSourceNotifier =
      ValueNotifier(EventDataSource([]));

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

    _eventDataSource = EventDataSource([]);

    _eventDataManager.eventsStream.listen((updatedEvents) {
      debugPrint(
          "[CalendarUI] Received ${updatedEvents.length} events from stream");

      final cleanEvents = updatedEvents.whereType<Event>().toList();

      for (final e in updatedEvents) {
        if (e is! Event) {
          debugPrint('❌ Found non-Event in stream: ${e.runtimeType} — $e');
        }
      }

      allEvents.value = cleanEvents;

      final newDataSource = EventDataSource(cleanEvents);
      calendarDataSourceNotifier.value = newDataSource;

      if (_selectedDate != null) {
        dailyEvents.value = _eventDataManager.getEventsForDate(_selectedDate!);
      }

      triggerCalendarHardRefresh();
    });

    _eventDataManager.onExternalEventUpdate = () {
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
    debugPrint("📦 Group fetched: \${updatedGroup.id}");
  }

  void dispose() {
    _eventDataManager.dispose();
    dailyEvents.dispose();
    allEvents.dispose();
    calendarRefreshKey.dispose();
  }

  Widget buildCalendar(BuildContext context, {double? height, double? width}) {
    return SizedBox(
      height: height,
      width: width,
      child: buildSfCalendar(
        context: context,
        controller: _controller,
        selectedView: _selectedView,
        onSelectedViewChanged: (view) {
          _selectedView = view;
        },
        onSelectedDateChanged: (date) {
          _selectedDate = date;
          _controller.selectedDate = _selectedDate;
          dailyEvents.value =
              _eventDataManager.getEventsForDate(_selectedDate!);
        },
        calendarRefreshKey: calendarRefreshKey,
        calendarDataSourceNotifier: calendarDataSourceNotifier,
        selectedDate: _selectedDate,
        allEvents: allEvents.value,
        calendarAppointmentBuilder: _calendarAppointmentBuilder,
        userRole: userRole,
        eventDataManager: _eventDataManager,
      ),
    );
  }
}
