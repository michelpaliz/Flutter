import 'dart:developer' as devtools show log;
import 'package:first_project/costume_widgets/color_manager.dart';
import 'package:first_project/models/custom_day_week.dart';
import 'package:first_project/models/meeting_data_source.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../constants/routes.dart';
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
  late final Group _group;
  late List<Event> _events;
  late DateTime _selectedDate;
  late StoreService _storeService;
  var userOrGroupObject;
  late List<Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _getEventsListFromGroup();
    _selectedDate = DateTime.now().toLocal();
    _storeService = StoreService.firebase();
    _appointments = [];
    // _getEventsListFromGroup();
  }

  int calculateDaysBetweenDates(DateTime startDate, DateTime endDate) {
    return endDate.difference(startDate).inDays;
  }

  //** Logic for my view */
  Future<void> _reloadScreen() async {
    _events = _group.calendar.events.cast<Event>(); //
    userOrGroupObject = _group;
  }

  Future<void> _getEventsListFromGroup() async {
    _group = widget.group; // Access the passed group
    _events = _group.calendar.events.cast<Event>();
    userOrGroupObject = _group;
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
          });
        }
      }
    });
  }

  Future<void> _removeGroupEvents({required Event event}) async {
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

  Future<void> _updateEvent(Event event) async {
    await _storeService.updateEvent(event);
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

    // Extract recurrence information from the RecurrenceRule object
    final recurrenceType = recurrenceRule?.recurrenceType.name;
    final repeatInterval = recurrenceRule?.repeatInterval ?? 1;
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
    }

    // Add the "UNTIL" parameter if "untilDate" is specified
    if (untilDate != null) {
      final untilDateString = DateFormat('yyyyMMddTHHmmss').format(untilDate);
      recurrenceRuleString += ';UNTIL=$untilDateString';
    }

    // Add the "COUNT" parameter
    recurrenceRuleString += ';COUNT=$count';

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
    return Scaffold(
        appBar: AppBar(
          title: Text('CALENDAR'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, groupSettings,
                    arguments: userOrGroupObject);
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _reloadScreen();
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
              height: 360, // Set the desired height for the calendar
              child: SfCalendar(
                view: CalendarView.month,
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
                viewHeaderStyle: ViewHeaderStyle(
                  backgroundColor: Color.fromARGB(255, 180, 237,
                      248), // Change the background color of the month header
                  dayTextStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'lato'), // Customize the text color
                  // Customize weekend text color
                ),

                // Customize other properties as needed
                monthViewSettings: MonthViewSettings(
                  agendaViewHeight: 30,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  appointmentDisplayCount: 5,
                  showTrailingAndLeadingDates: false,
                  navigationDirection: MonthNavigationDirection.vertical,
                  monthCellStyle: MonthCellStyle(
                    backgroundColor: Color.fromARGB(
                        255, 31, 46, 113), // Background color for month cells
                    trailingDatesBackgroundColor: Color(
                        0xff216583), // Background color for trailing dates
                    leadingDatesBackgroundColor:
                        Color(0xff216583), // Background color for leading dates
                    todayBackgroundColor: Color.fromARGB(255, 125, 236,
                        232), // Background color for today's date
                    textStyle: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Arial',
                      color: Colors.white, // Text color for month cells
                    ),
                    todayTextStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial',
                      color: Colors.black, // Text color for today's date
                    ),
                    trailingDatesTextStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      fontFamily: 'Arial',
                      color: Colors.white, // Text color for trailing dates
                    ),
                    leadingDatesTextStyle: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      fontFamily: 'Arial',
                      color: Colors.white, // Text color for leading dates
                    ),
                  ),
                ),
                // dataSource: EventDataSource(_events),
                // Set the data source for the calendar using _getCalendarDataSource()
                dataSource: MeetingDataSource(_getCalendarDataSource()),
                // Use the generated appointments
              ),
            ),

            // Expanded section below the calendar
            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 255, 255, 255),
                child: _getNotesForDate(_selectedDate),
              ),
            ),
          ],
        ));
  }

  Widget _getNotesForDate(DateTime date) {
    print('Selected Date VARIABLE: $date');

    final eventsForDate = _getEventsForDate(date);
    print('EVENTS FOR DATE VARIABLE: $eventsForDate');

    eventsForDate.sort((a, b) => a.startDate.compareTo(b.startDate));

    final formattedDate = DateFormat('MMMM d, yyyy').format(date);

    return Column(
      children: [
        SizedBox(height: 8), // Add spacing above the title
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'NOTES FOR $formattedDate'.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 32, 116, 165),
              fontFamily: 'righteous',
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            return ListView.builder(
              itemCount: eventsForDate.length,
              itemBuilder: (context, index) {
                final event = eventsForDate[index];
                final startTime = event.startDate;
                final endTime = event.endDate;
                final startTimeText = DateFormat('hh:mm a').format(startTime);
                final endDateText = DateFormat('hh:mm a').format(endTime);

                return Dismissible(
                  key: Key(event.id), // Use a unique key for each item
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
                        await _showRemoveConfirmationDialog(event, context);
                    return confirm;
                  },

                  onDismissed: (direction) {
                    // Remove the event from the list and update the UI
                    setState(() {
                      eventsForDate.removeAt(index);
                    });

                    // Also, remove the event from your data source (Firestore or wherever you're storing events)
                    _removeGroupEvents(event: event);
                  },

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              width: 5,
                              color: ColorManager()
                                  .getColor(event.eventColorIndex),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      startTimeText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Text(
                                      endDateText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        DateFormat('EEE, MMM d  -  ')
                                            .format(startTime),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('EEE, MMM d')
                                            .format(endTime),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          event.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          size: 20,
                                          color:
                                              Color.fromARGB(255, 96, 153, 199),
                                        ),
                                        onPressed: () {
                                          _editEvent(event, context);
                                        },
                                      ),
                                      // IconButton(
                                      //   icon: Icon(
                                      //     Icons.delete,
                                      //     size: 20,
                                      //     color:
                                      //         Color.fromARGB(255, 238, 105, 96),
                                      //   ),
                                      //   onPressed: () {
                                      //     _showRemoveConfirmationDialog(
                                      //         event, context);
                                      //   },
                                      // ),
                                      Transform.scale(
                                        scale: 0.8,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        Stack(
          children: [
            Container(
              // padding: EdgeInsets.all(5),
              child: Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(
                        25), // Adjust the border radius as needed
                  ),
                  width: 50, // Adjust the width of the button
                  height: 50, // Adjust the height of the button
                  child: IconButton(
                    // padding: EdgeInsets.all(5),
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
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}
