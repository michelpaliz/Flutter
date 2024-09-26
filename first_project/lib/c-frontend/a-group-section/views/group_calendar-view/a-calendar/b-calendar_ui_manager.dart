import 'package:first_project/a-models/event.dart';
import 'package:first_project/a-models/event_data_source.dart';
import 'package:first_project/b-backend/database_conection/node_services/event_services.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/appointment/appointment_builder.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/backend/4-event_data_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/b-event_display_manager.dart';
import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarUIManager {
  final CalendarController _controller = CalendarController();
  final List<Event> events;
  final EventDisplayManager _eventDisplayManager;
  final EventDataManager _eventDataManager;
  final String userRole;

  late CalendarAppointmentBuild _calendarAppointmentBuilder;

  CalendarView _selectedView = CalendarView.month;
  DateTime? _selectedDate;

  CalendarUIManager(
    this._eventDataManager, {
    required this.events,
    required EventService eventService,
    required EventDisplayManager eventDisplayManager,
    required this.userRole,
  }) : _eventDisplayManager = eventDisplayManager {
    _calendarAppointmentBuilder = CalendarAppointmentBuild(
      _eventDataManager,
      _eventDisplayManager, // Corrected parameter
    );
  }

  Widget buildCalendar(BuildContext context, double height, double width) {
    Color textColor = ThemeColors.getTextColor(context);

    return Container(
      height: height,
      width: width,
      child: SfCalendar(
        allowedViews: [
          CalendarView.month,
          CalendarView.schedule,
          CalendarView.day,
          CalendarView.week,
          CalendarView.timelineDay,
          CalendarView.timelineWeek,
          CalendarView.timelineMonth,
        ],
        controller: _controller,
        onViewChanged: (ViewChangedDetails viewChangedDetails) {
          Future.delayed(Duration.zero, () {
            _selectedView = _controller.view!;
          });
        },
        showNavigationArrow: true,
        firstDayOfWeek: DateTime.monday,
        initialSelectedDate: DateTime.now(),
        view: _selectedView,
        showDatePickerButton: true,
        headerStyle: CalendarHeaderStyle(
          textAlign: TextAlign.center,
        ),
        onSelectionChanged: (CalendarSelectionDetails details) {
          if (details.date != null) {
            Future.delayed(Duration.zero, () {
              _selectedDate = details.date!.toUtc();
            });
          }
        },
        scheduleViewSettings: ScheduleViewSettings(
          appointmentItemHeight: 150,
          monthHeaderSettings: MonthHeaderSettings(
            monthFormat: 'MMMM, yyyy',
            height: 100,
            textAlign: TextAlign.left,
            backgroundColor: Color.fromARGB(255, 3, 87, 102),
            monthTextStyle: TextStyle(
              fontFamily: 'lato',
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        viewHeaderStyle: ViewHeaderStyle(
          dateTextStyle: TextStyle(fontFamily: 'lato', color: Colors.black),
          backgroundColor: Color.fromARGB(255, 180, 237, 248),
          dayTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'lato',
          ),
        ),
        monthCellBuilder: (context, details) {
          return _buildMonthCell(details);
        },
        monthViewSettings: MonthViewSettings(
          showAgenda: true,
          agendaItemHeight: 85,
          dayFormat: 'EEE',
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          appointmentDisplayCount: 4,
          showTrailingAndLeadingDates: false,
          navigationDirection: MonthNavigationDirection.vertical,
        ),
        appointmentBuilder:
            (BuildContext context, CalendarAppointmentDetails details) {
          dynamic appointment = details.appointments.first;

          switch (_controller.view) {
            case CalendarView.week:
              return _calendarAppointmentBuilder.buildWeekAppointment(
                  details, textColor, context, appointment);
            case CalendarView.timelineDay:
              return _calendarAppointmentBuilder.buildTimelineDayAppointment(
                  details, textColor, context, appointment);
            case CalendarView.timelineWeek:
              return _calendarAppointmentBuilder.buildTimelineWeekAppointment(
                  details, textColor, context, appointment);
            case CalendarView.timelineMonth:
              return _calendarAppointmentBuilder.buildTimelineMonthAppointment(
                  details, textColor, context, appointment);
            default:
              return _calendarAppointmentBuilder.defaultBuildAppointment(
                details,
                textColor,
                context,
                _selectedView.toString(),
                userRole, // Pass user role to the default build method
              );
          }
        },
        dataSource: EventDataSource(events),
      ),
    );
  }

  // Custom month cell builder for month view
  Widget _buildMonthCell(MonthCellDetails details) {
    // Add your custom month cell building logic here
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Center(
        child: Text(
          details.date.day.toString(),
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
