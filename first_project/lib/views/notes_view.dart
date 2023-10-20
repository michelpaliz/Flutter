import 'dart:async';
import 'dart:developer' as devtools show log;
import 'package:first_project/constants/routes.dart';
import 'package:first_project/costume_widgets/color_manager.dart';
import 'package:first_project/costume_widgets/drawer/my_drawer.dart';
import 'package:first_project/models/custom_day_week.dart';
import 'package:first_project/models/meeting_data_source.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/utilities/sharedprefs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../services/firestore/implements/firestore_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  //**Global variables */
  late List<Event> _events;
  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();
  Stream<List<Event>> eventsStream = Stream.empty();
  late AuthService _authService= AuthService.firebase();
  late User userOrGroupObject;
  late DateTime _selectedDate;
  late StoreService _storeService;
  late List<Appointment> _appointments;
  late CalendarView _selectedView;
  late CalendarController _controller;
  late double screenWidth;
  late double calendarHeight;
  late User? _user;

  @override
  void initState() {
    super.initState();
    _events = [];
    _getEventsListFromUser();
    _selectedDate = DateTime.now().toLocal();
    _storeService = StoreService.firebase();
    _selectedView = CalendarView.month;
    _controller = CalendarController();
    _appointments = [];
  }

  void _updateCalendarDataSource() {
    setState(() {
      _appointments = _getCalendarDataSource();
    });
  }

  Future<void> _reloadData() async {
    _getEventsListFromUser();
    _updateCalendarDataSource(); // Call the method here to update the data source
  }

  Future<void> _getEventsListFromUser() async {
    _user = _authService.costumeUser;

    if (_user != null) {
      setState(() {
        _events = _user!.events;
        userOrGroupObject = _user!;
      });
    }
  }

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

  Future<void> _removeGroupEvents({required Event event}) async {
    // Event? event = await _storeService.getEventById(eventId, groupId);

    // Remove the event from Firestore
    await _storeService.removeEvent(event.id);

    // Update the events for the user in Firestore
    _user!.events.removeWhere((e) => e.id == event.id);
    await _storeService.updateEvent(event);

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

  //**Building the UI for the view*/
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
      subject: event.title,
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

  //** UI FOR THE VIEW */

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    // Set the globalVariable based on the screen size
    if (screenWidth < 600) {
      calendarHeight = 650; // Set a value for smaller screens
    } else {
      calendarHeight = 700; // Set a different value for larger screens
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('CALENDAR'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Navigator.pushNamed(context, groupSettings,
                //     arguments: userOrGroupObject);
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
              height: calendarHeight,
              child: SfCalendar(
                allowedViews: [
                  CalendarView.day,
                  CalendarView.week,
                  CalendarView.month,
                  CalendarView.schedule
                ],
                controller: _controller,
                onViewChanged: (ViewChangedDetails viewChangedDetails) {
                  Future.delayed(Duration.zero, () {
                    setState(() {
                      _selectedView = _controller.view!;
                    });
                  });
                },

                firstDayOfWeek: DateTime.monday,
                initialSelectedDate: DateTime.now(),
                view: _selectedView,
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
                      color: Color.fromARGB(255, 195, 225,
                          224), // Change the background color for weekends.
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
                      color: Color.fromARGB(255, 158, 199,
                          220), // Use the default background color for other days.
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
                      future: _storeService.getEventFromUserById(
                          _user!, appointment.id),
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
                                _editEvent(event,
                                    context); // Call your edit event function when the appointment is tapped
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
                                  final bool confirm =
                                      await _showRemoveConfirmationDialog(
                                          event, context);
                                  return confirm;
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
                                            ],
                                          ),
                                        ),

                                        // Transform.scale(
                                        //   scale: 0.8,
                                        //   child: Checkbox(
                                        //     value: event.done,
                                        //     onChanged: (newValue) {
                                        //       setState(() {
                                        //         event.done = newValue!;
                                        //         _updateEvent(event);
                                        //       });
                                        //     },
                                        //   ),
                                        // ),
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
                    // Retrieve the Event data
                    // Retrieve the Event data asynchronously
                    return FutureBuilder<Event?>(
                      future: _storeService.getEventFromUserById(
                          _user!, appointment.id.toString()),
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
                          arguments: userOrGroupObject);
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
