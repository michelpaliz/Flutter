import 'dart:developer' as devtools show log;
import 'package:first_project/costume_widgets/color_manager.dart';
import 'package:first_project/models/custom_day_week.dart';
import 'package:first_project/models/meeting_data_source.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/views/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../routes/routes.dart';
import '../costume_widgets/drawer/my_drawer.dart';
import '../models/event.dart';
import '../models/group.dart';
import '../services/firestore/implements/firestore_service.dart';

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
  late StoreService _storeService;
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

  //** Logic for my view */

  @override
  void initState() {
    super.initState();
    _group = widget.group; // Access the passed group
    _users = _group.userRoles; // Access the
    _events = [];
    _selectedDate = DateTime.now().toLocal();
    _storeService = StoreService.firebase();
    _selectedView = CalendarView.month;
    _controller = CalendarController();
    _authService = AuthService.firebase();
    _appointments = [];
    _getEventsListFromGroup();
  }

  Future<void> _getEventsListFromGroup() async {
    // _user = await SharedPrefsUtils.getUserFromPreferences();
    _user = _authService.costumeUser;
    devtools.log('This is the user fetched $_user'.toString());
    setState(() {
      if (_user != null) {
        userRole = _getRoleByName(
            _user!.name)!; // This might be nullable, no need for ! here
        _events = _group.calendar.events;
      }
      _users = _group.userRoles;
      print('THIS IS GROUP $_group'.toString);
      _userOrGroupObject = _group;
      _updateCalendarDataSource(); // Call the method here to update the data source
    });
  }

  int calculateDaysBetweenDates(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  void _updateCalendarDataSource() {
    setState(() {
      _appointments = _getCalendarDataSource();
    });
  }

  Future<void> _updateEvent(Event event) async {
    await _storeService.updateEvent(event);
  }

  Future<void> _reloadData() async {
    Group? group = await _storeService.getGroupFromId(_group.id);
    setState(() {
      _appointments = [];
      if (group != null) {
        _group = group;
        _events = group.calendar.events;
      }
    });
    _updateCalendarDataSource(); // Call the method here to update the data source
  }

  String? _getRoleByName(String name) {
    return _users[name];
  }

  void _editEvent(Event event, BuildContext context) {
    Navigator.pushNamed(
      context,
      editEvent,
      arguments: event,
    ).then((result) {
      if (result != null && result is Event) {
        // Update the event in the eventsList
        final index = _events.indexWhere((e) => e.id == result.id);
        if (index >= 0) {
          setState(() {
            _events[index] = result;
            _updateCalendarDataSource(); // Update the data source after the change
          });
        }
      }
    });
  }

  Future<void> _removeGroupEvents({required Event event}) async {
    // Event? event = await _storeService.getEventById(eventId, groupId);

    // Remove the event from Firestore
    await _storeService.removeEvent(event.id);

    // Update the events for the user in Firestore
    _group.calendar.events.removeWhere((e) => e.id == event.id);
    await _storeService.updateGroup(_group);

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
          content: Text('Are you sure you want to remove this event?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Remove'),
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
    final List<Event> eventsForDate = _events.where((event) {
      final DateTime eventStartDate = event.startDate.toLocal();
      final DateTime eventEndDate = event.endDate.toLocal();

      // Check if the event falls on the selected date
      return eventStartDate.isBefore(date.add(Duration(days: 1))) &&
          eventEndDate.isAfter(date);
    }).toList();

    return eventsForDate;
  }

  List<Appointment> _getCalendarDataSource() {
    _appointments = <Appointment>[];

    devtools.log('Events ---- $_events'.toString());
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
        ));
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
      startTime: startDate, // Generate
      endTime: endDate, // Generate
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
    _screenWidth = MediaQuery.of(context).size.width;
    // Set the globalVariable based on the screen size
    if (_screenWidth < 600) {
      _calendarHeight = 650; // Set a value for smaller screens
    } else {
      _calendarHeight = 700; // Set a different value for larger screens
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('CALENDAR'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, groupSettings,
                    arguments: _userOrGroupObject);
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _reloadData();
              },
            ),
          ],
        ),
        drawer: MyDrawer(),
        body:
            // Replace TableCalendar with SfCalendar
            Column(
          children: [
            // Calendar widget
            Container(
              // height: 360, // Set the desired height for the calendar
              height: _calendarHeight,
              child: SfCalendar(
                allowedViews: [CalendarView.month, CalendarView.schedule],
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
                // Set the initial selected date (or update it when the user selects a date)
                onSelectionChanged: (CalendarSelectionDetails details) {
                  if (details.date != null) {
                    // Use Future.delayed to schedule the state update after the build is complete
                    Future.delayed(Duration.zero, () {
                      // Update the selected date when the user selects a date
                      setState(() {
                        _selectedDate = details.date!.toLocal();
                      });
                      // Fetch events for the selected date
                      _getEventsForDate(_selectedDate);
                    });
                  }
                },
                scheduleViewSettings: ScheduleViewSettings(
                  appointmentItemHeight: 70,
                ),
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: Color.fromARGB(255, 180, 237,
                      248), // Change the background color of the month header
                  dayTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'lato'), // Customize the text color
                  // Customize weekend text color
                ),
                monthCellBuilder: (context, details) {
                  // Check if the current date is a weekend (Saturday or Sunday).
                  if (details.date.weekday == DateTime.saturday ||
                      details.date.weekday == DateTime.sunday) {
                    return Container(
                      color: Color.fromARGB(255, 195, 225, 224), // Change the background color for weekends.
                      child: Center(
                        child: Text(
                          details.date.day.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      color: Color.fromARGB(255, 158, 199, 220), // Use the default background color for other days.
                      child: Center(
                        child: Text(details.date.day.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    );
                  }
                },
                // Customize other properties as needed
                monthViewSettings: MonthViewSettings(
                  showAgenda: true,
                  agendaItemHeight: 85,
                  dayFormat: 'EEE',
                  // agendaViewHeight: 100,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  appointmentDisplayCount: 5,
                  showTrailingAndLeadingDates: false,
                  navigationDirection: MonthNavigationDirection.vertical,
                ),
                appointmentBuilder:
                    (BuildContext context, CalendarAppointmentDetails details) {
                  final appointment = details.appointments.first;

                  if (_selectedView == CalendarView.month) {
                    return FutureBuilder<Event?>(
                      future: _storeService.getEventFromGroupById(
                          appointment.id, _group.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator
                              .adaptive(); // Loading indicator
                        } else if (snapshot.hasError) {
                          return Text(
                              'Error: ${snapshot.error}'); // Display error message
                        } else {
                          final Event? event = snapshot.data;
                          if (event != null) {
                            return GestureDetector(
                              onTap: () {
                                if (userRole == 'Administrator' ||
                                    userRole == 'Co-Administrator') {
                                  _editEvent(event,
                                      context); // Call your edit event function when the appointment is tapped
                                }
                              },
                              child: Dismissible(
                                key: Key(appointment.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  if (userRole == 'Administrator' ||
                                      userRole == 'Co-Administrator') {
                                    final bool confirm =
                                        await _showRemoveConfirmationDialog(
                                            event, context);
                                    return confirm;
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Permission Denied'),
                                          content: Text('You are not an administrator to remove this item.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
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
                                  // Remove the event from the list and update the UI
                                  setState(() {
                                    _appointments.remove(appointment);
                                  });

                                  // Also, remove the event from your data source (Firestore or wherever you're storing events)
                                  _removeGroupEvents(event: event);
                                },
                                child: Container(
                                    margin: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          width: 10,
                                          color: ColorManager()
                                              .getColor(event.eventColorIndex),
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 16), // Add left margin
                                          child: Row(
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    DateFormat(
                                                            'EEE, MMM d  -  ')
                                                        .format(
                                                            event.startDate),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat('EEE, MMM d')
                                                        .format(event.endDate),
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 16), // Add left margin
                                          child: Row(
                                            children: [
                                              Text(
                                                '${event.startDate.hour}-${event.startDate.minute}  -',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                '${event.endDate.hour}-${event.endDate.minute}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 16), // Add left margin
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.event,
                                                size: 20,
                                                color: ColorManager().getColor(
                                                    event.eventColorIndex),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                event.title,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: () {
                                                  // Navigate to another view when the second icon is pressed
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) {
                                                      return EventDetail(
                                                          event: event);
                                                    }),
                                                  );
                                                },
                                                child: Icon(
                                                    Icons
                                                        .more_rounded, // Replace with your desired icon
                                                    size:
                                                        20, // Adjust the size as needed
                                                    color: ColorManager()
                                                        .getColor(event
                                                            .eventColorIndex) // Change the color as needed
                                                    ),
                                              ),
                                              SizedBox(width: 8),
                                              Container(
                                                height:
                                                    20, // Set the desired height for the Checkbox
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
                                        ),
                                      ],
                                    )),
                              ),
                            );
                          } else {
                            return Container(
                              child: Text(
                                'No events found for this date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  } else {
                    // Retrieve the Event data asynchronously
                    return FutureBuilder<Event?>(
                      future: _storeService.getEventFromGroupById(
                          appointment.id.toString(), _group.id.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Handle loading state
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          // Handle error state
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final event = snapshot.data;
                          if (event != null) {
                            // Return your design for other views with the fetched event data
                            return GestureDetector(
                              onTap: () {
                                // Add code to handle appointment editing when tapped
                                _editEvent(event,
                                    context); // Replace with your edit appointment function
                              },
                              child: Container(
                                width: details.bounds.width,
                                height: details.bounds.height,
                                margin: EdgeInsets.only(bottom: 10),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: ColorManager()
                                        .getColor(event.eventColorIndex),
                                    width: 1,
                                  ),
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
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '${event.endDate.hour}-${event.endDate.minute}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.event_available_rounded,
                                          size: 15,
                                          color: ColorManager()
                                              .getColor(event.eventColorIndex),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Text(
                                            event.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Text(
                                'No event data found for this appointment');
                          }
                        }
                      },
                    );
                  }
                },
                // dataSource: EventDataSource(_events),
                // Set the data source for the calendar using _getCalendarDataSource()
                dataSource: MeetingDataSource(_getCalendarDataSource()),
                // Use the generated appointments
              ),
            ),
            if (userRole == 'Administrator' || userRole == 'Co-Administrator')
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(
                          25), // Adjust the border radius as needed
                    ),
                    width: 50, // Adjust the width of the button
                    height: 50, // Adjust the height of the button
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30, // Adjust the icon size as needed
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, addEvent,
                            arguments: _userOrGroupObject);
                      },
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 5,
            )
          ],
        ));
  }
}
