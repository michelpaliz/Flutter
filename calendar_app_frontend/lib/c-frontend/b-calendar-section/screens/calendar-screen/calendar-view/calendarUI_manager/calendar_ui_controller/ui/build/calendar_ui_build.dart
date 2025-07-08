
import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/appointment-widgets/appointment_builder.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/calendar-view/calendarUI_manager/calendar_mont_cell.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/calendar-view/calendarUI_manager/calendar_styles.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/calendar-view/calendarUI_manager/calendar_ui_controller/helper/buildAppointmentWidget.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart' show EventDataManager;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

Widget buildSfCalendar({
  required BuildContext context,
  required CalendarController controller,
  required CalendarView selectedView,
  required void Function(CalendarView view) onSelectedViewChanged,
  required void Function(DateTime date) onSelectedDateChanged,
  required ValueNotifier<int> calendarRefreshKey,
  required ValueNotifier<CalendarDataSource> calendarDataSourceNotifier,
  required DateTime? selectedDate,
  required List<Event> allEvents,
  required CalendarAppointmentBuild calendarAppointmentBuilder,
  required String userRole,
  required EventDataManager eventDataManager, // 👈 ADD THIS
}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final textColor = getTextColor(context);
  final backgroundColor = getBackgroundColor(context).withOpacity(0.8);
  final fontSize = MediaQuery.of(context).size.width * 0.035;

  return ValueListenableBuilder<int>(
    valueListenable: calendarRefreshKey,
    builder: (context, refreshKey, _) {
      return Container(
        decoration: buildContainerDecoration(backgroundColor),
        child: SfCalendar(
          key: ValueKey(refreshKey),
          controller: controller,
          dataSource: calendarDataSourceNotifier.value,
          view: selectedView,
          allowedViews: CalendarView.values,
          onViewChanged: (_) => onSelectedViewChanged(controller.view!),
          onSelectionChanged: (details) {
            if (details.date != null) {
              onSelectedDateChanged(details.date!);
            }
          },
          monthCellBuilder: (context, details) => buildMonthCell(
            context: context,
            details: details,
            selectedDate: selectedDate,
            events: allEvents,
          ),
          appointmentBuilder: (context, details) {
            return buildAppointmentWidget(
              details: details,
              view: selectedView,
              textColor: textColor,
              context: context,
              builder: calendarAppointmentBuilder,
              manager: eventDataManager,
              userRole: userRole,
            );
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
