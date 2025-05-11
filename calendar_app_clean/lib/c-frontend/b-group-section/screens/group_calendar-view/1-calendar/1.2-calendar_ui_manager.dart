import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/event_appointment/event/event_data_source.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/2-appointment/2.1-appointment_builder.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/b-event_display_manager.dart';
import 'package:first_project/d-stateManagement/event_data_manager.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
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

  CalendarUIManager({
    required this.events,
    required Group group,
    required EventService eventService,
    required EventDisplayManager eventDisplayManager,
    required this.userRole,
    required GroupManagement groupManagement,
  })  : _eventDisplayManager = eventDisplayManager,
        _eventDataManager = EventDataManager(
          events,
          group: group,
          eventService: eventService,
          groupManagement: groupManagement,
        ) {
    _calendarAppointmentBuilder = CalendarAppointmentBuild(
      _eventDataManager,
      _eventDisplayManager,
    );
  }

  Widget buildCalendar(BuildContext context, double height, double width) {
    Color textColor = ThemeColors.getTextColor(context);

    double appointmentItemHeight = height * 0.15;
    double monthHeaderHeight = height * 0.1;
    double agendaItemHeight = height * 0.1;
    double fontSize = width * 0.04;

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
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        onSelectionChanged: (CalendarSelectionDetails details) {
          if (details.date != null) {
            Future.delayed(Duration.zero, () {
              _selectedDate = details.date!.toUtc();
            });
            _eventDataManager.getEventsForDate(details.date!);
          }
        },
        scheduleViewSettings: ScheduleViewSettings(
          appointmentItemHeight: appointmentItemHeight,
          monthHeaderSettings: MonthHeaderSettings(
            monthFormat: 'MMMM, yyyy',
            height: monthHeaderHeight,
            textAlign: TextAlign.left,
            backgroundColor: Color.fromARGB(255, 3, 87, 102),
            monthTextStyle: TextStyle(
              fontFamily: 'lato',
              fontSize: fontSize,
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
            fontSize: fontSize,
          ),
        ),
        monthCellBuilder: _buildMonthCell,
        monthViewSettings: MonthViewSettings(
          showAgenda: true,
          agendaItemHeight: agendaItemHeight,
          dayFormat: 'EEE',
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          appointmentDisplayCount: 4,
          showTrailingAndLeadingDates: false,
          navigationDirection: MonthNavigationDirection.vertical,
        ),
        appointmentBuilder: (context, details) {
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
                userRole,
              );
          }
        },
        dataSource: EventDataSource(events),
      ),
    );
  }

  Widget _buildMonthCell(BuildContext context, MonthCellDetails details) {
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
