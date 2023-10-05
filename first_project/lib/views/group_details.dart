import 'package:first_project/costume_widgets/color_manager.dart';
import 'package:first_project/models/event_data_source.dart';
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

  List<Appointment> getCalendarDataSource() {
    _appointments = <Appointment>[];

    // Convert your custom events to Appointment objects
    for (var event in _events) {
      _appointments.add(Appointment(
        startTime: event.startDate,
        endTime: event.endDate,
        subject: event.title,
        color: ColorManager().getColor(event.eventColorIndex),
      ));
    }

    return _appointments;
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
              height: 390, // Set the desired height for the calendar
              child: SfCalendar(
                view: CalendarView.month,
                timeZone: 'Europe/Madrid',
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

                // Customize other properties as needed
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode:
                      MonthAppointmentDisplayMode.appointment,
                  // navigationDirection: MonthNavigationDirection.horizontal,
                  appointmentDisplayCount: 2,
                  showTrailingAndLeadingDates:
                      false, // Hide trailing and leading date
                ),
                dataSource: EventDataSource(_events),
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
    print('EVENTS FOR DATE VARIABLE: $eventsForDate' );

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
