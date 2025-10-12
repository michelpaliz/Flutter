import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hexora/a-models/group_model/event/event_data_source.dart';
import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/b-backend/group_mng_flow/event/domain/event_domain.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_screen_logic/widgets/cells_widgets/calendar_mont_cell.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_screen_logic/widgets/month_schedule_img/calendar_styles.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/widget_appointment/appointment_builder.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/bridge/event_display_manager.dart';
import 'package:hexora/c-frontend/d-event-section/utils/color_manager.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/cells_widgets/calendar_styles.dart';

class CalendarUIController {
  final CalendarController _controller = CalendarController();
  final EventDisplayManager _eventDisplayManager;
  final EventDomain _eventDomain;
  final GroupDomain groupDomain;
  final String userRole;

  List<Event> _lastEventsSnapshot = [];

  late final EventDataSource _eventDataSource;
  final ValueNotifier<int> calendarRefreshKey = ValueNotifier(0);
  Timer? _refreshDebounce;

  /// 👇 Public getter if needed
  EventDomain get eventDomain => _eventDomain;

  /// 👇 Selected-day events
  final ValueNotifier<List<Event>> dailyEvents = ValueNotifier([]);

  /// 👇 All visible events (expanded) for current range
  final ValueNotifier<List<Event>> allEvents = ValueNotifier([]);

  /// 👇 DataSource notifier → refresh SfCalendar without rebuilding whole tree
  final ValueNotifier<EventDataSource> calendarDataSourceNotifier =
      ValueNotifier(EventDataSource([]));

  late final CalendarAppointmentBuild _calendarAppointmentBuilder;
  CalendarView _selectedView = CalendarView.month;
  DateTime? _selectedDate;

  StreamSubscription<List<Event>>? _eventsSub;

  CalendarUIController({
    required EventDomain eventDomain,
    required EventDisplayManager eventDisplayManager,
    required this.groupDomain,
    required this.userRole,
  })  : _eventDomain = eventDomain,
        _eventDisplayManager = eventDisplayManager {
    _calendarAppointmentBuilder = CalendarAppointmentBuild(
      _eventDomain,
      _eventDisplayManager,
    );

    _eventDataSource = EventDataSource([]);

    // ✅ Listen to repo-owned stream exposed by EventDomain
    _eventsSub = _eventDomain.watchEvents().listen((updatedEvents) {
      debugPrint("[CalendarUI] 📥 ${updatedEvents.length} events from stream");

      if (!_areEventsEqual(updatedEvents, _lastEventsSnapshot)) {
        _lastEventsSnapshot = List<Event>.from(updatedEvents);

        // update calendar datasource + notifiers
        calendarDataSourceNotifier.value.updateEvents(updatedEvents);
        allEvents.value = List<Event>.from(updatedEvents);

        if (_selectedDate != null) {
          dailyEvents.value = _eventsForDate(_selectedDate!, updatedEvents);
        }

        // Just visually refresh; do not talk back to EventDomain here.
        _triggerCalendarHardRefreshSafe();
      } else {
        debugPrint("✅ Events are the same — skipping calendar refresh.");
      }
    });
  }

  // --- Helpers ---------------------------------------------------------------

  bool _areEventsEqual(List<Event> a, List<Event> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].hashCode != b[i].hashCode) return false;
    }
    return true;
  }

  List<Event> _eventsForDate(DateTime date, List<Event> source) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return source
        .where((e) => e.startDate.isBefore(end) && e.endDate.isAfter(start))
        .toList();
  }

  /// Safe hard refresh that won’t run during build/layout/paint phases.
  void _triggerCalendarHardRefreshSafe() {
    Future<void> run() async {
      debugPrint("🔁 Triggering calendar hard refresh...");
      debugPrintStack(
          label: '🔍 Stack trace for calendar refresh', maxFrames: 5);

      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(const Duration(milliseconds: 100), () {
        calendarRefreshKey.value++;
      });
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    final inBuild = phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.postFrameCallbacks;

    if (inBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        run();
      });
    } else {
      run();
    }
  }

  /// Manual “force fetch” from repo via EventDomain, then UI refresh.
  Future<void> requestHardDataRefresh({
    required BuildContext context,
    required String groupId,
    required DateTime visibleStart,
    required DateTime visibleEnd,
  }) async {
    Future<void> run() async {
      await _eventDomain.manualRefresh(context);
      _triggerCalendarHardRefreshSafe();
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    final inBuild = phase == SchedulerPhase.transientCallbacks ||
        phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.postFrameCallbacks;

    if (inBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) => run());
    } else {
      await run();
    }
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
        await groupDomain.groupRepository.getGroupById(groupId);

    // Defer setting currentGroup to avoid “markNeedsBuild during build”
    WidgetsBinding.instance.addPostFrameCallback((_) {
      groupDomain.currentGroup = updatedGroup;
    });

    debugPrint("📦 Group fetched: ${updatedGroup.id}");
  }

  void dispose() {
    _refreshDebounce?.cancel();
    _eventsSub?.cancel(); // ✅ close subscription
    _eventDomain.dispose();
    dailyEvents.dispose();
    allEvents.dispose();
    calendarRefreshKey.dispose();
  }

  // --- Calendar widget -------------------------------------------------------

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
            dataSource: calendarDataSourceNotifier.value,
            view: _selectedView,
            allowedViews: CalendarView.values,
            onViewChanged: (_) => _selectedView = _controller.view!,
            onSelectionChanged: (details) {
              if (details.date != null) {
                _selectedDate = details.date!;
                _controller.selectedDate = _selectedDate;

                // Compute from current snapshot (no domain call)
                dailyEvents.value = _eventsForDate(
                  _selectedDate!,
                  allEvents.value,
                );
              }
            },
            scheduleViewMonthHeaderBuilder: (context, details) =>
                buildScheduleMonthHeader(details),
            monthCellBuilder: (context, details) => buildMonthCell(
              context: context,
              details: details,
              selectedDate: _selectedDate,
              events: allEvents.value,
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

                final event = appt;
                final cardColor = ColorManager().getColor(
                  event.eventColorIndex,
                );

                switch (_selectedView) {
                  case CalendarView.schedule:
                    return _calendarAppointmentBuilder.buildScheduleAppointment(
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
                    return _calendarAppointmentBuilder.buildWeekAppointment(
                      details,
                      textColor,
                      event,
                      userRole,
                    );
                  case CalendarView.timelineDay:
                    return _calendarAppointmentBuilder
                        .buildTimelineDayAppointment(
                      details,
                      textColor,
                      event,
                      userRole,
                    );
                  case CalendarView.timelineWeek:
                    return _calendarAppointmentBuilder
                        .buildTimelineWeekAppointment(
                      details,
                      textColor,
                      event,
                      userRole,
                    );
                  case CalendarView.timelineMonth:
                    return _calendarAppointmentBuilder
                        .buildTimelineMonthAppointment(
                      details,
                      textColor,
                      event,
                      userRole,
                    );
                  default:
                    if (_selectedView == CalendarView.week ||
                        _selectedView == CalendarView.workWeek ||
                        _selectedView == CalendarView.day) {
                      return _calendarAppointmentBuilder.buildWeekAppointment(
                        details,
                        textColor,
                        event,
                        userRole,
                      );
                    } else {
                      return _calendarAppointmentBuilder.defaultBuildAppointment(
                        details,
                        textColor,
                        context,
                        _selectedView.toString(),
                        userRole,
                      );
                    }
                }
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
            viewHeaderStyle: buildViewHeaderStyle(
              fontSize,
              textColor,
              isDarkMode,
            ),
            scheduleViewSettings: buildScheduleSettings(
              fontSize,
              backgroundColor,
            ),
            monthViewSettings: buildMonthSettings(),
          ),
        ).animate().fadeIn(duration: 500.ms);
      },
    );
  }
}
