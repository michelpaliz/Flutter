import 'dart:async';
import 'dart:developer' as devtools show log;
import 'package:first_project/services/user/user_provider.dart';
import 'package:first_project/styles/app_bar_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/routes.dart';
import '../costume_widgets/drawer/my_drawer.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../services/auth/implements/auth_service.dart';
import '../services/firestore/implements/firestore_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  //**Global variables */
  List<Event>? eventsList;
  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();
  Stream<List<Event>> eventsStream = Stream.empty();
  StoreService storeService = StoreService.firebase();
  var userOrGroupObject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getEventsListFromUser();
      // Set a default selectedDate when the screen loads
      setState(() {
        selectedDate = DateTime
            .now(); // Set it to the current date or any default date you prefer
      });
    });
  }

  //** Logic for my view */
  Future<void> _reloadScreen() async {
    await _getEventsListFromUser();
  }

  Future<void> _getEventsListFromUser() async {
    // User? user = await getCurrentUser();
    AuthService.firebase()
        .getCurrentUserAsCustomeModel()
        .then((User? fetchedUser) {
      if (fetchedUser != null) {
        setState(() {
          currentUser = fetchedUser;
          eventsList = currentUser!.events;
          userOrGroupObject = currentUser;
        });
      }
    });
  }

  List<Event> getEventsForDate(DateTime date) {
    final eventsForDate = eventsList?.where((event) {
          return event.startDate.year == date.year &&
              event.startDate.month == date.month &&
              event.startDate.day == date.day;
        }).toList() ??
        [];

    return eventsForDate;
  }

  void _editEvent(Event event, BuildContext context) {
    Navigator.pushNamed(
      context,
      editNote,
      arguments: event,
    ).then((result) {
      if (result != null && result is Event) {
        // Update the event in the eventsList
        final index = eventsList?.indexWhere((e) => e.id == result.id);
        if (index != null && index >= 0) {
          setState(() {
            eventsList?[index] = result;
          });
        }
      }
    });
  }

  Future<void> _updateEvent(Event event) async {
    await storeService.updateEvent(event);
  }

  //**Building the UI for the view*/
  @override
  Widget build(BuildContext context) {
    return Theme(
        data: AppBarStyles.themeData,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'CALENDAR',
              style: TextStyle(
                color: const Color.fromARGB(
                    255, 255, 255, 255), // Set the title color to black
                fontSize: 20,
              ),
            ),
            actions: [
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
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(4),
                    child: Center(
                        // child: Text(
                        //   'CALENDAR',
                        //   style: TextStyle(
                        //     fontFamily: 'lato',
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        ),
                  ),
                  TableCalendar<Event>(
                    eventLoader: (date) {
                      return getEventsForDate(date);
                    },
                    firstDay: DateTime.utc(2023, 1, 1),
                    focusedDay: DateTime.now(),
                    lastDay: DateTime.utc(2023, 12, 31),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, _) {
                        final isFocusedDay = isSameDay(date, focusedDay);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isFocusedDay
                                    ? Colors.blue
                                    : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    color: isFocusedDay
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      todayBuilder: (context, date, _) {
                        final isFocusedDay = isSameDay(date, focusedDay);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isFocusedDay
                                    ? Colors.blue
                                    : Colors.transparent,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    color: isFocusedDay
                                        ? Colors.blue
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      selectedBuilder: (context, date, events) {
                        final isFocusedDay = isSameDay(date, focusedDay);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFocusedDay
                                  ? Colors.blue
                                  : Colors.transparent,
                            ),
                            margin: EdgeInsets.all(2),
                            padding: EdgeInsets.all(2),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  date.day.toString(),
                                  style: TextStyle(
                                    color: isFocusedDay
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: isFocusedDay
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Custom Layout', // Your custom content for the focused day
                                  style: TextStyle(
                                    color: isFocusedDay
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (selectedDate != null)
                    Expanded(
                      child: Container(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        child: Center(
                          child: getNotesForDate(selectedDate!),
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
                      Navigator.pushNamed(context, addNote,
                          arguments: userOrGroupObject);
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget getNotesForDate(DateTime date) {
    final eventsForDate = getEventsForDate(date);

    eventsForDate.sort((a, b) => a.startDate.compareTo(b.startDate));

    final formattedDate = DateFormat('MMMM d, yyyy').format(date);

    return Column(
      children: [
        SizedBox(height: 16), // Add spacing above the title
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'NOTES FOR $formattedDate'.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
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

            return ListTile(
              title: Text(
                timeText.toUpperCase(),
                style: TextStyle(
                  color: timeColor,
                ),
              ),
              subtitle: Text(
                event.note,
                style: TextStyle(
                  color: eventColor,
                ),
              ),
              trailing: Checkbox(
                value: event.done, // Reflects the event.done field
                onChanged: (newValue) {
                  // Update the 'done' field in your data model
                  setState(() {
                    event.done = newValue!;
                    _updateEvent(event);
                  });
                },
              ),
            );
          },
        )),
      ],
    );
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
                // Remove the event from Firestore
                await storeService.removeEvent(event.id);

                // Update the events for the user in Firestore
                User? user = await getCurrentUser();
                if (user != null) {
                  user.events =
                      eventsList!.where((e) => e.id != event.id).toList();
                  await storeService.updateUser(user);
                }

                // Remove the event from the eventList
                setState(() {
                  eventsList?.removeWhere((e) => e.id == event.id);
                });

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
