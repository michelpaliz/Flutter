import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/calendar-view/calendarUI_manager/calendar_mont_cell.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ReactiveMonthCell extends StatelessWidget {
  final MonthCellDetails details;
  final DateTime? selectedDate;
  final bool isDarkMode;

  const ReactiveMonthCell({
    required this.details,
    required this.selectedDate,
    required this.isDarkMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final eventDataManager = context.watch<EventDataManager>();

    return ValueListenableBuilder<List<Event>>(
      valueListenable: eventDataManager.eventsNotifier,
      builder: (context, events, _) {
        return buildMonthCell(
          context: context,
          details: details,
          selectedDate: selectedDate,
          // isDarkMode: isDarkMode,
          events: events,
        );
      },
    );
  }
}
