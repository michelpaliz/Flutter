// calendar_surface.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/presentation/view_adapater/widgets/widgets_cells/cells_widgets/calendar_mont_cell.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/presentation/view_adapater/widgets/widgets_cells/cells_widgets/calendar_styles.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/presentation/view_adapater/widgets/widgets_cells/month_schedule_img/calendar_styles.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sf;

import '../adapter/calendar_state.dart';
import 'appointment_builder_bridge.dart';

// calendar_surface.dart
class CalendarSurface extends StatefulWidget {
  final CalendarState state;
  final AppointmentBuilderBridge apptBridge;

  const CalendarSurface({
    super.key,
    required this.state,
    required this.apptBridge,
  });

  @override
  State<CalendarSurface> createState() => _CalendarSurfaceState();
}

class _CalendarSurfaceState extends State<CalendarSurface> {
  final sf.CalendarController _controller = sf.CalendarController();
  sf.CalendarView _selectedView = sf.CalendarView.month;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = getTextColor(context);
    final backgroundColor = getBackgroundColor(context).withOpacity(0.8);
    final fontSize = MediaQuery.of(context).size.width * 0.035;

    // ✅ Rebuild when the DATA changes, not a synthetic key.
    return ValueListenableBuilder<sf.CalendarDataSource>(
      valueListenable: widget.state.dataSource,
      builder: (_, ds, __) {
        return ValueListenableBuilder<List<Event>>(
          valueListenable: widget.state.allEvents,
          builder: (_, events, __) {
            return Container(
              decoration: buildContainerDecoration(backgroundColor),
              child: sf.SfCalendar(
                // changing the key forces SfCalendar to fully pick up a new ds
                key: ObjectKey(ds),
                controller: _controller,
                dataSource: ds,
                view: _selectedView,
                allowedViews: sf.CalendarView.values,
                onViewChanged: (_) => _selectedView = _controller.view!,
                onSelectionChanged: (d) {
                  if (d.date != null) {
                    _selectedDate = d.date!;
                    _controller.selectedDate = _selectedDate;
                    widget.state.selectedDate = _selectedDate;
                    widget.state.dailyEvents.value = widget.state.eventsForDate(
                        _selectedDate!, widget.state.allEvents.value);
                  }
                },
                scheduleViewMonthHeaderBuilder: (context, d) =>
                    buildScheduleMonthHeader(d),
                monthCellBuilder: (context, d) => buildMonthCell(
                  context: context,
                  details: d,
                  selectedDate: _selectedDate,
                  events: events, // ← always up to date
                ),
                appointmentBuilder: (context, details) => widget.apptBridge
                    .build(context, _selectedView, details, textColor),
                selectionDecoration:
                    const BoxDecoration(color: Colors.transparent),
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
            ).animate().fadeIn(duration: 300.ms);
          },
        );
      },
    );
  }
}
