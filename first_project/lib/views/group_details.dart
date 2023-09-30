import 'package:first_project/costume_widgets/costume_merged_cell.dart';
import 'package:first_project/models/event_date_range.dart';
import 'package:first_project/views/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/routes.dart';
import '../costume_widgets/drawer/my_drawer.dart';
import '../models/event.dart';
import '../models/group.dart';
import '../services/auth/implements/auth_service.dart';
import '../services/firestore/implements/firestore_service.dart';
import '../styles/app_bar_styles.dart';

class GroupDetails extends StatefulWidget {
  final Group group;

  const GroupDetails({required this.group, Key? key}) : super(key: key);

  @override
  State<GroupDetails> createState() => _GroupDetailsState();
}

class _GroupDetailsState extends State<GroupDetails> {
  late final Group _group;
  List<Event>? _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  StoreService storeService = new StoreService.firebase();
  AuthService authService = new AuthService.firebase();
  var userOrGroupObject;
  List<Event> filteredEvents = [];
//  final List<EventDateRange> eventDateRanges = preprocessEventData(events);

  @override
  void initState() {
    super.initState();

    _getEventsListFromGroup();

    // Initialize selectedEvents with events for the current date
    // _selectedEvents = getEventsForDate(DateTime.now());
  }

  // Update the onTap handler to call _onDateSelected
  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      // _selectedEvents = getEventsForDate(date);
    });
  }

  //** Logic for my view */
  Future<void> _reloadScreen() async {
    _events = _group.calendar.events.cast<Event>(); //
    userOrGroupObject = _group;
  }

  Future<void> _getEventsListFromGroup() async {
    _group = widget.group; // Access the passed group
    _events = _group.calendar.events.cast<Event>(); //
    userOrGroupObject = _group;
  }

  List<Event> _getEventsForDate(DateTime date) {
    final eventsForDate = _events?.where((event) {
          // Convert event dates to UTC for comparison
          final eventStartDateUtc = event.startDate.toUtc();
          final eventEndDateUtc = event.endDate.toUtc();

          // Convert the specified date to UTC
          final selectedDateUtc = date.toUtc();

          // Check if the event starts on or before the specified date and ends after it
          return eventStartDateUtc
                  .isBefore(selectedDateUtc.add(Duration(days: 1))) &&
              eventEndDateUtc.isAfter(selectedDateUtc);
        }).toList() ??
        [];

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
        final index = _events?.indexWhere((e) => e.id == result.id);
        if (index != null && index >= 0) {
          setState(() {
            _events?[index] = result;
          });
        }
      }
    });
  }

  Future<void> _removeGroupEvents(Event event) async {
    // Remove the event from Firestore
    await storeService.removeEvent(event.id);

    // Update the events for the user in Firestore

    _group.calendar.events = _events!.where((e) => e.id != event.id).toList();
    await storeService.updateGroup(_group);

    // Remove the event from the eventListP_)
    setState(() {
      _events?.removeWhere((e) => e.id == event.id);
    });

    Navigator.of(context).pop(); // Close the dialog
  }

  Future<void> _updateEvent(Event event) async {
    await storeService.updateEvent(event);
  }

  void _showRemoveConfirmationDialog(Event event, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Removal'),
          content: Text('Are you sure you want to remove this event?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Remove'),
              onPressed: () async {
                _removeGroupEvents(event);
              },
            ),
          ],
        );
      },
    );
  }

  //** UI FOR THE VIEW */

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppBarStyles.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'CALENDAR',
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontSize: 20,
            ),
          ),
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
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  // width: 400, // Set the desired width
                  // height: 400, // Set the desired height
                  child: TableCalendar<Event>(
                    calendarStyle: CalendarStyle(
                      cellMargin: EdgeInsets.all(10.0),
                      outsideDaysVisible: false, //
                    ),
                    eventLoader: (date) {
                      filteredEvents = _getEventsForDate(date);

                      // final eventsForFocusedDay = _getEventsForDate(_focusedDay);

                      // Merge the events for the selected day and the focused day
                      final allEvents = [
                        ...filteredEvents,
                        // ...eventsForFocusedDay
                      ];

                      return [];
                    },
                    firstDay: DateTime.utc(2023, 1, 1),
                    focusedDay: DateTime.now(),
                    lastDay: DateTime.utc(2023, 12, 31),
                    calendarBuilders: CalendarBuilders(
                      //*defaultBuilder: Customize the appearance of a non-selected cell. It uses a GestureDetector to detect taps on the cell.
                      defaultBuilder: (context, date, events) {
                        final isSelected = isSameDay(date, _selectedDate);

                        // Check if there are events for this date
                        if (filteredEvents.isNotEmpty) {
                          // Merge cells if there are events on this date
                          return GestureDetector(
                            onTap: () {
                              _onDateSelected(date);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .transparent, // Background color for event portion
                                    ),
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: const Color.fromARGB(255, 14, 13,
                                            13), // Text color for event number
                                      ),
                                    ),
                                  ),
                                  for (var event in filteredEvents)
                                    Text(
                                      event.title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            const Color.fromARGB(255, 4, 4, 4),
                                        backgroundColor: event.eventColor, // Background color for event
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Use your default cell design for days without events, including the day number
                          return GestureDetector(
                            onTap: () {
                              _onDateSelected(date);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Color.fromARGB(255, 26, 105, 166)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color.fromARGB(255, 7, 7, 7)
                                          : Color.fromARGB(255, 19, 126, 161),
                                      // Adjust text color for focused day
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },

                      todayBuilder: (context, date, events) {
                        final isSelected = isSameDay(date, _selectedDate);
                        final isToday = isSameDay(date, DateTime.now());

                        if (filteredEvents.isNotEmpty) {
                          // Merge cells if there are events on this date
                          return GestureDetector(
                            onTap: () {
                              _onDateSelected(date);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? Colors.white
                                          : Colors
                                              .blue, // Background color for event portion on focused day
                                    ),
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isToday
                                            ? Colors.black
                                            : Colors
                                                .blue, // Text color for event number on focused day
                                      ),
                                    ),
                                  ),
                                  for (var event in filteredEvents)
                                    Text(
                                      event.title,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: const Color.fromARGB(
                                            255, 14, 13, 13),
                                        backgroundColor: event.eventColor
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Use your default cell design for today's cell
                          return GestureDetector(
                            onTap: () {
                              _onDateSelected(date);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    // color: isSelected ? Colors.blue : Colors.transparent,
                                    ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      color: isToday
                                          ? Colors.blue
                                          : Colors
                                              .black, // Adjust text color for today
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      // selectedBuilder: (context, date, events) {
                      //   //*selectedBuilder: Customize the appearance of a selected cell.

                      // },
                    ),
                  ),
                ),
                if (_selectedDate != null)
                  Expanded(
                    child: Container(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Center(
                        child: getNotesForDate(_selectedDate!),
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(1),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, addEvent,
                        arguments: userOrGroupObject);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getNotesForDate(DateTime date) {
    final eventsForDate = _getEventsForDate(date);

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
          child: ListView.separated(
            itemCount: eventsForDate.length,
            separatorBuilder: (context, index) => Divider(),
            itemBuilder: (context, index) {
              final event = eventsForDate[index];
              final startTime = event.startDate;
              final endTime = event.endDate;
              final timeText =
                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')} - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
              final timeColor = const Color.fromARGB(202, 33, 149, 243);
              final eventColor = Colors.black;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetail(event: event),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    timeText.toUpperCase(),
                    style: TextStyle(
                      color: timeColor,
                    ),
                  ),
                  subtitle: Text(
                    event.title,
                    style: TextStyle(
                      color: eventColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize
                        .min, // Ensure that the row takes up minimum space.
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editEvent(event, context);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Implement the logic to remove the event
                          _showRemoveConfirmationDialog(event, context);
                        },
                      ),
                      Checkbox(
                        value: event.done,
                        onChanged: (newValue) {
                          setState(() {
                            event.done = newValue!;
                            _updateEvent(event);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
