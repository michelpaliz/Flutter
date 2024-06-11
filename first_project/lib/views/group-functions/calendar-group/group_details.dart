import 'dart:developer' as devtools show log;

import 'package:first_project/l10n/AppLocalitationMethod.dart';
import 'package:first_project/models/custom_day_week.dart';
import 'package:first_project/models/meeting_data_source.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/services/node_services/event_services.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:first_project/utilities/color_manager.dart';
import 'package:first_project/views/event-logic/event_detail.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../enums/routes/appRoutes.dart';
import '../../../models/event.dart';
import '../../../models/group.dart';
import '../../../styles/drawer-style-menu/my_drawer.dart';

class GroupDetails extends StatefulWidget {
  final Group group;

  const GroupDetails({required this.group, Key? key}) : super(key: key);

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  late Group _group;
  late List<Event> _events;
  late DateTime _selectedDate;
  // late FirestoreService _storeService;
  late AuthService _authService;
  var _userOrGroupObject;
  late List<Appointment> _appointments;
  late CalendarView _selectedView;
  late CalendarController _controller;
  late double _screenWidth;
  late double _calendarHeight;
  late Map<String, String> _users;
  String userRole = "";
  late User? _user;
  late ProviderManagement? _providerManagement;
  late EventService _eventService;
  late bool _dataLoaded = false;

  //** Logic for my view */

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _group = widget.group;
    _users = _group.userRoles;
    _events = [];
    _selectedDate = DateTime.now().toUtc();
    _selectedView = CalendarView.month;
    _controller = CalendarController();
    _authService = AuthService.firebase();
    _appointments = [];
    _eventService = EventService();
    _user = _authService.costumeUser;
    if (_user != null) {
      userRole = _getRoleByName(_user!.userName)!;
      _events = _group.calendar.events;
    }
    _users = _group.userRoles;
    _userOrGroupObject = _group;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _providerManagement = Provider.of<ProviderManagement>(context);
    if (_providerManagement!.currentGroup != _group) {
      _group = _providerManagement!.currentGroup!;
      _events = _group.calendar.events;
    }
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_dataLoaded) {
  //     _providerManagement = Provider.of<ProviderManagement>(context);
  //     _group = widget.group; // Initialize _group here

  //     // Update other state variables as needed
  //     _users = _group.userRoles;
  //     _events = [];
  //     _selectedDate = DateTime.now().toUtc();
  //     _selectedView = CalendarView.month;
  //     _controller = CalendarController();
  //     _authService = AuthService.firebase();
  //     _appointments = [];
  //     _eventService = EventService();
  //     _user = _authService.costumeUser;
  //     if (_user != null) {
  //       userRole = _getRoleByName(_user!.userName)!;
  //       _events = _group.calendar.events;
  //     }
  //     _users = _group.userRoles;
  //     _userOrGroupObject = _group;

  //     // Defer the call to update current group and data source using addPostFrameCallback
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (_providerManagement.currentGroup == null ||
  //           _providerManagement.currentGroup != _group) {
  //         // Set _providerManagement.currentGroup only if necessary
  //         _providerManagement.currentGroup = _group;
  //         _events = _providerManagement.currentGroup!.calendar.events;
  //       }
  //       _updateCalendarDataSource();
  //     });

  //     _dataLoaded = true;
  //   }
  // }

  int calculateDaysBetweenDates(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  void _updateCalendarDataSource() {
    setState(() {
      _appointments = _getCalendarDataSource();
    });
  }

  Future<void> _updateEvent(Event event) async {
    await _eventService.updateEvent(event.id, event);
  }

  Future<void> _reloadData() async {
    // Group? group = await _storeService.getGroupFromId(_group.id);
    Group? group =
        await _providerManagement!.groupService.getGroupById(_group.id);
    setState(() {
      _appointments = [];
      _group = group;
      _events = group.calendar.events;
    });
    _updateCalendarDataSource(); // Call the method here to update the data source
  }

  String? _getRoleByName(String userName) {
    return _users[userName];
  }

  void _editEvent(Event event, BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.editEvent,
      arguments: event,
    ).then((result) {
      if (result != null && result is Event) {
        final index = _events.indexWhere((e) => e.id == result.id);
        if (index >= 0) {
          setState(() {
            _events[index] = result;
            _updateCalendarDataSource();
            _controller.selectedDate =
                _controller.selectedDate; // Force refresh
          });
        }
      }
    });
  }

  Future<void> _removeGroupEvents({required Event event}) async {
    // Remove the event from Firestore
    await _eventService.deleteEvent(event.id);
    // Update the events for the user in Firestore
    _group.calendar.events.removeWhere((e) => e.id == event.id);
    // await _storeService.updateGroup(_group);
    await _providerManagement!.updateGroup(_group);

    // Update the UI by removing the event from the list
    setState(() {
      _events.remove(event);
    });
  }

  Future<bool> _showRemoveConfirmationDialog(
      Event event, BuildContext context) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Removal'),
          //  AppLocalizations.of(context)!.changeView,
          content: Text(AppLocalizations.of(context)!.removeEvent),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.remove),
              onPressed: () async {
                Navigator.of(context).pop(true);
                confirmed = true;

                // Remove the event from the list and update the UI
                setState(() {
                  _events.remove(event);
                });

                // Also, remove the event from your data source (Firestore or wherever you're storing events)
                await _removeGroupEvents(event: event);
              },
            ),
          ],
        );
      },
    );
    return confirmed;
  }

  /** This method is responsible for retrieving a list of events that occur on a specific date, which is passed as the date parameter. */
  List<Event> _getEventsForDate(DateTime date) {
    // Convert the input date to UTC to ensure consistent comparisons
    final DateTime utcDate = DateTime.utc(date.year, date.month, date.day);

    final List<Event> eventsForDate = _events.where((event) {
      // Convert event start and end dates to UTC
      final DateTime eventStartDate = event.startDate.toUtc();
      final DateTime eventEndDate = event.endDate.toUtc();

      // Check if the event falls on the selected date in UTC
      return eventStartDate.isBefore(utcDate.add(Duration(days: 1))) &&
          eventEndDate.isAfter(utcDate);
    }).toList();

    return eventsForDate;
  }

  List<Appointment> _getCalendarDataSource() {
    _appointments = [];
    // Iterate through each event
    for (var event in _events) {
      // Check if the event has a recurrence rule
      if (event.recurrenceRule != null) {
        // Generate recurring appointments based on the recurrence rule
        var appointment = _generateRecurringAppointment(event);
        _appointments.add(appointment);
      } else {
        // If the event doesn't have a recurrence rule, add it as a single appointment
        _appointments.add(Appointment(
          id: event.id, // Assign a unique ID here
          startTime: event.startDate,
          endTime: event.endDate,
          subject: event.title,
          color: ColorManager().getColor(event.eventColorIndex),
        )); // Update eventColorIndex
      }
    }

    return _appointments;
  }

  Appointment _generateRecurringAppointment(Event event) {
    // Get the start date and end date from the event
    final startDate = event.startDate;
    final endDate = event.endDate;

    // Calculate the number of days between startDate and endDate (avoiding leap years)
    final count = calculateDaysBetweenDatesAvoidLeapYears(startDate, endDate);

    // Get the recurrence rule details
    final recurrenceRule = event.recurrenceRule;

    devtools.log('Recurrence Rule is ---- $recurrenceRule'.toString());

    // Extract recurrence information from the RecurrenceRule object
    final recurrenceType = recurrenceRule?.recurrenceType.name;
    final repeatInterval = recurrenceRule?.repeatInterval;
    final untilDate = recurrenceRule?.untilDate;

    // Define a list of specific days of the week for weekly recurrence
    final List<String> weeklyDays = [];
    final daysOfWeek = recurrenceRule?.daysOfWeek;
    if (daysOfWeek != null) {
      for (var e in daysOfWeek) {
        final abbreviation = CustomDayOfWeek.getPattern(e.name.toString());
        print('abbreviation ---- $abbreviation');
        weeklyDays.add(abbreviation);
      }
    }

    // Create a new instance of Appointment for the specific instance
    final appointment = Appointment(
      id: event.id, // Generate a unique ID for the appointment
      startTime: startDate.toUtc(), // Generate
      endTime: endDate.toUtc(), // Generate
      // startTimeZone: 'Europe/Madrid',
      // endTimeZone: 'Europe/Madrid',
      subject: event.description ?? "",
      color: ColorManager().getColor(event.eventColorIndex),
    );

    // Create a recurrence rule string pattern
    String recurrenceRuleString = '';
    if (recurrenceType == 'Daily') {
      recurrenceRuleString = 'FREQ=DAILY;INTERVAL=$repeatInterval';
    } else if (recurrenceType == 'Weekly' && weeklyDays.isNotEmpty) {
      recurrenceRuleString = 'FREQ=WEEKLY;INTERVAL=$repeatInterval;BYDAY=';
      final daysOfWeekString = weeklyDays.join(',');
      recurrenceRuleString += daysOfWeekString;
    } else if (recurrenceType == 'Monthly') {
      recurrenceRuleString = 'FREQ=MONTHLY;INTERVAL=$repeatInterval';

      // Add the BYMONTHDAY rule based on the day of the month from the start date
      final dayOfMonth = startDate.day;
      recurrenceRuleString += ';BYMONTHDAY=$dayOfMonth';
    } else if (recurrenceType == 'Yearly') {
      recurrenceRuleString = 'FREQ=YEARLY;INTERVAL=$repeatInterval';

      // Add the BYMONTH rule based on the month index from the start date
      final monthIndex = startDate.month;
      recurrenceRuleString += ';BYMONTH=$monthIndex';

      // Add the BYMONTHDAY rule based on the day of the month from the start date
      final dayOfMonth = startDate.day;
      recurrenceRuleString += ';BYMONTHDAY=$dayOfMonth';
    }

    // Add the "UNTIL" parameter if "untilDate" is specified
    if (untilDate != null) {
      final untilDateString = DateFormat('yyyyMMddTHHmmss').format(untilDate);
      recurrenceRuleString += ';UNTIL=$untilDateString';
    }

    // Add the "COUNT" parameter only if count is greater than 0
    if (count > 0) {
      recurrenceRuleString += ';COUNT=$count';
    }

    appointment.recurrenceRule = recurrenceRuleString;

    print('This is the recurrence rule: $appointment.recurrenceRule');

    return appointment;
  }

  int calculateDaysBetweenDatesAvoidLeapYears(
      DateTime startDate, DateTime endDate) {
    int count = 0;
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      count++;
      currentDate = currentDate.add(Duration(days: 1));
      if (currentDate.month == 2 && currentDate.day == 29) {
        // Skip leap year day
        currentDate = DateTime(currentDate.year + 1, 3, 1);
      }
    }

    return count;
  }

  //** UI FOR THE VIEW */

  @override
  Widget build(BuildContext context) {
    _setScreenWidthAndCalendarHeight(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      drawer: MyDrawer(),
      body: _buildBody(context),
    );
  }

  void _setScreenWidthAndCalendarHeight(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    if (_screenWidth < 600) {
      _calendarHeight = 650; // Set a value for smaller screens
    } else {
      _calendarHeight = 700; // Set a different value for larger screens
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.calendar.toUpperCase()),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.groupSettings,
              arguments: _userOrGroupObject,
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            _reloadData();
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildCalendar(context),
        if (userRole == 'Administrator' || userRole == 'Co-Administrator')
          _buildAddEventButton(context),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCalendar(BuildContext context) {
    Color textColor = ThemeColors.getTextColor(context);
    return Container(
      height: _calendarHeight,
      child: SfCalendar(
        allowedViews: [
          CalendarView.month,
          CalendarView.schedule,
          CalendarView.day
        ],
        controller: _controller,
        onViewChanged: (ViewChangedDetails viewChangedDetails) {
          Future.delayed(Duration.zero, () {
            setState(() {
              _selectedView = _controller.view!;
            });
          });
        },
        showNavigationArrow: true,
        firstDayOfWeek: DateTime.monday,
        initialSelectedDate: DateTime.now(),
        view: _selectedView,
        showDatePickerButton: true,
        timeZone: 'Europe/Madrid',
        headerStyle: CalendarHeaderStyle(
          textAlign: TextAlign.center, // Center-align the month name
        ),
        onSelectionChanged: (CalendarSelectionDetails details) {
          if (details.date != null) {
            Future.delayed(Duration.zero, () {
              DateTime selectedDateUtc = details.date!.toUtc();
              setState(() {
                _selectedDate = selectedDateUtc.toUtc();
              });
              _getEventsForDate(selectedDateUtc);
            });
          }
        },
        scheduleViewSettings: ScheduleViewSettings(
          appointmentItemHeight: 70,
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
          appointmentDisplayCount: 5,
          showTrailingAndLeadingDates: false,
          navigationDirection: MonthNavigationDirection.vertical,
        ),
        appointmentBuilder:
            (BuildContext context, CalendarAppointmentDetails details) {
          return _buildAppointment(details, textColor, context);
        },
        dataSource: MeetingDataSource(_getCalendarDataSource()),
      ),
    );
  }

  Widget _buildMonthCell(MonthCellDetails details) {
    if (details.date.weekday == DateTime.saturday ||
        details.date.weekday == DateTime.sunday) {
      return Container(
        color: Color.fromARGB(255, 195, 225, 224),
        child: Center(
          child: Text(
            details.date.day.toString(),
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'lato',
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } else {
      return Container(
        color: Color.fromARGB(255, 158, 199, 220),
        child: Center(
          child: Text(
            details.date.day.toString(),
            style: TextStyle(fontFamily: 'lato', color: Colors.black),
          ),
        ),
      );
    }
  }

  Widget _buildAppointment(CalendarAppointmentDetails details, Color textColor,
      BuildContext context) {
    final appointment = details.appointments.first;
    if (_selectedView == CalendarView.month) {
      return FutureBuilder<Event?>(
        future: _eventService.getEventById(appointment.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator.adaptive();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final Event? event = snapshot.data;
            if (event != null) {
              return _buildEventDetails(event, context, textColor, appointment);
            } else {
              return Container(
                child: Text(
                  'No events found for this date',
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              );
            }
          }
        },
      );
    } else {
      return FutureBuilder<Event?>(
        future: _eventService.getEventById(appointment.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final event = snapshot.data;
            if (event != null) {
              return _buildNonMonthViewEvent(event, details, textColor);
            } else {
              return Text('No event data found for this appointment');
            }
          }
        },
      );
    }
  }

  Widget _buildEventDetails(
      Event event, BuildContext context, Color textColor, appointment) {
    return GestureDetector(
      onTap: () {
        if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
          _editEvent(event, context);
        }
      },
      child: Dismissible(
        key: Key(appointment.id),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          if (userRole == 'Administrator' || userRole == 'Co-Administrator') {
            final bool confirm =
                await _showRemoveConfirmationDialog(event, context);
            return confirm;
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppLocalizations.of(context)!.permissionDenied),
                  content:
                      Text(AppLocalizations.of(context)!.permissionDeniedInf),
                  actions: <Widget>[
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
          return false;
        },
        onDismissed: (direction) {
          setState(() {
            _appointments.remove(appointment);
          });
          _removeGroupEvents(event: event);
        },
        child: _buildEventContent(event, textColor),
      ),
    );
  }

  Widget _buildEventContent(Event event, Color textColor) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            width: 10,
            color: ColorManager().getColor(event.eventColorIndex),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventDateRow(event, textColor),
          SizedBox(height: 3),
          _buildEventTimeRow(event, textColor),
          SizedBox(height: 8),
          _buildEventTitleRow(event, textColor),
        ],
      ),
    );
  }

  Widget _buildEventDateRow(Event event, Color textColor) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text(
            AppLocalizationsMethods.of(context)?.formatDate(event.startDate) ??
                '',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
          ),
          Text("  -  "),
          Text(
            AppLocalizationsMethods.of(context)?.formatDate(event.endDate) ??
                '',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTimeRow(Event event, Color textColor) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Text(
            AppLocalizationsMethods.of(context)!.formatHours(event.startDate) +
                "   - ",
            style: TextStyle(fontSize: 15, color: textColor),
          ),
          SizedBox(width: 8),
          Text(
            AppLocalizationsMethods.of(context)!.formatHours(event.endDate),
            style: TextStyle(fontSize: 15, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTitleRow(Event event, Color textColor) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      child: Row(
        children: [
          Icon(Icons.event,
              size: 20, color: ColorManager().getColor(event.eventColorIndex)),
          SizedBox(width: 7),
          Text(event.title, style: TextStyle(fontSize: 15, color: textColor)),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return EventDetail(event: event);
              }));
            },
            child: Icon(Icons.more_rounded,
                size: 20,
                color: ColorManager().getColor(event.eventColorIndex)),
          ),
          SizedBox(width: 8),
          Container(
            height: 20,
            child: Checkbox(
              value: event.done,
              onChanged: (newValue) {
                setState(() {
                  event.done = newValue!;
                  _updateEvent(event);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNonMonthViewEvent(
      Event event, CalendarAppointmentDetails details, Color textColor) {
    return GestureDetector(
      onTap: () {
        _editEvent(event, context);
      },
      child: Container(
        width: details.bounds.width,
        height: details.bounds.height,
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
              color: ColorManager().getColor(event.eventColorIndex), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(2),
              child: Row(
                children: [
                  Text(
                    '${event.startDate.hour}-${event.startDate.minute}  -',
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${event.endDate.hour}-${event.endDate.minute}',
                    style: TextStyle(fontSize: 12, color: textColor),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.event_available_rounded,
                    size: 15,
                    color: ColorManager().getColor(event.eventColorIndex)),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Text(
                    event.title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddEventButton(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(25),
          ),
          width: 50,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 25),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addEvent,
                  arguments: _userOrGroupObject);
            },
          ),
        ),
      ),
    );
  }
}
