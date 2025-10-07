import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/b-backend/core/event/domain/event_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_screen_logic/widgets/cells_widgets/calendar_mont_cell.dart';
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
    final eventDataManager = context.watch<EventDomain>();

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
