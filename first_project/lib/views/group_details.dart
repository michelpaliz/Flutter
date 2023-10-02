import 'package:first_project/costume_widgets/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/routes.dart';
import '../costume_widgets/drawer/my_drawer.dart';
import '../models/event.dart';
import '../models/group.dart';
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
  late DateTime _focusedDay;
  late DateTime _selectedDate;
  late StoreService _storeService;
  var userOrGroupObject;
  late List<Event> _filteredEvents;
  final GlobalKey<ScaffoldState> contextStorageKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getEventsListFromGroup();
    _focusedDay = DateTime.now();
    _selectedDate = DateTime.now();
    _storeService = StoreService.firebase();
    _filteredEvents = [];
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

  Future<void> _removeGroupEvents({required Event event}) async {
    // Remove the event from Firestore
    await _storeService.removeEvent(event.id);

    // Update the events for the user in Firestore
    _group.calendar.events.removeWhere((e) => e.id == event.id);
    await _storeService.updateGroup(_group);

    // Update the UI by removing the event from the list
    setState(() {
      _events!.remove(event);
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
                  _events!.remove(event);
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

  //** UI FOR THE VIEW */

  @override
  Widget build(BuildContext context) {
    //** We define the colors for the view  */
    const Color colorMoreEvents = Color.fromARGB(255, 61, 133, 209);
    const Color colorBorderCell = Color.fromARGB(255, 12, 31, 50);
    const Color colorWeekends = Color.fromARGB(255, 5, 81, 91);

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
                    // onDaySelected: (selectedDay, focusedDay) => _focusedDay ,
                    calendarStyle: CalendarStyle(
                      cellMargin: EdgeInsets.all(10.0),
                      outsideDaysVisible: false, //
                    ),
                    eventLoader: (date) {
                      _filteredEvents = _getEventsForDate(date);
                      return [];
                    },
                    firstDay: DateTime.utc(2023, 1, 1),
                    focusedDay: _selectedDate,
                    lastDay: DateTime.utc(2023, 12, 31),
                    calendarBuilders: CalendarBuilders(
                      //*defaultBuilder: Customize the appearance of a non-selected cell. It uses a GestureDetector to detect taps on the cell.
                      defaultBuilder: (context, date, events) {
                        final isSelected = isSameDay(date, _selectedDate);
                        final isSunday = date.weekday == DateTime.sunday;
                        final isSaturday = date.weekday == DateTime.saturday;

                        // Check if there are events for this date
                        if (_filteredEvents.isNotEmpty) {
                          // Display the first event
                          final firstEvent = _filteredEvents[0];

                          return InkWell(
                            onTap: () {
                              _onDateSelected(date);
                            },
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected
                                            ? colorBorderCell
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          date.day.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSunday || isSaturday
                                                ? colorWeekends
                                                : isSelected
                                                    ? const Color.fromARGB(
                                                        255, 7, 7, 7)
                                                    : Color.fromARGB(
                                                        255, 19, 126, 161),
                                          ),
                                        ),
                                        Text(
                                          firstEvent.title,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: const Color.fromARGB(
                                                255, 4, 4, 4),
                                            backgroundColor: ColorManager()
                                                .getColor(
                                                    firstEvent.eventColorIndex),
                                          ),
                                        ),
                                        if (_filteredEvents.length > 1)
                                          Text(
                                            "+${_filteredEvents.length - 1} more events",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: colorMoreEvents,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Use your default cell design for days without events
                          return GestureDetector(
                            onTap: () {
                              _onDateSelected(date);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? colorBorderCell
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    date.day.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSunday || isSaturday
                                          ? colorWeekends
                                          : isSelected
                                              ? Color.fromARGB(255, 9, 51, 80)
                                              : Color.fromARGB(
                                                  255, 19, 126, 161),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },

                      todayBuilder: (context, date, events) {
                        final isToday = isSameDay(date, _focusedDay);
                        final isSelected = isSameDay(date, _selectedDate);

                        // Check if there are events for this date
                        if (_filteredEvents.isNotEmpty) {
                          // Display the first event
                          final firstEvent = _filteredEvents[0];

                          return GestureDetector(
                            onTap: () {
                              if (isToday) {
                                _onDateSelected(date);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isToday
                                      ? Colors.blue
                                      : Colors.transparent,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          isToday ? Colors.white : Colors.blue,
                                    ),
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isToday
                                            ? Colors.black
                                            : Colors.blue,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    firstEvent.title,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          const Color.fromARGB(255, 14, 13, 13),
                                      backgroundColor: ColorManager()
                                          .getColor(firstEvent.eventColorIndex),
                                    ),
                                  ),
                                  if (_filteredEvents.length > 1)
                                    Text(
                                      "+${_filteredEvents.length - 1} more events",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorMoreEvents,
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
                              if (isToday) {
                                _onDateSelected(date);
                              }
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
                                      color:
                                          isToday ? Colors.white : Colors.blue,
                                    ),
                                    child: Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        color: isToday
                                            ? Colors.black
                                            : Colors.blue,
                                      ),
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
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: getNotesForDate(_selectedDate),
                  ),
                ),
              ],
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
              padding: EdgeInsets.all(5),
              child: Positioned(
                bottom: 10, // Adjust the bottom position as needed
                right: 0, // Center the button horizontally
                left: 0,
                child: Center(
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
            ),
          ],
        ),
      ],
    );
  }
}
