import 'dart:developer' as devtools show log;

import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/utiliies/sharedprefs.dart';
import 'package:first_project/utiliies/userUtils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/routes.dart';
import '../enums/menu_action.dart';
import '../models/event.dart';
import '../models/user.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  List<Event>? eventsList;
  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();

  Future<void> _getListFromUser() async {
    User? user = await getCurrentUser();
    eventsList = user?.events;
    SharedPrefsUtils.storeUser(user!);
    setState(() {}); // Refresh the UI with the updated eventsList
  }

  @override
  void initState() {
    super.initState();
    _getListFromUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAIN UI'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              // devtools.log(value.toString());
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  devtools.log(shouldLogout.toString());
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
                default:
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                    value: MenuAction.logout, child: Text('Log out'))
              ];
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(5),
                child: Center(
                  child: Text(
                    'CALENDAR',
                    style: TextStyle(
                      fontFamily: 'lato',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                            color:
                                isFocusedDay ? Colors.blue : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                color:
                                    isFocusedDay ? Colors.blue : Colors.black,
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
                            color:
                                isFocusedDay ? Colors.blue : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                color:
                                    isFocusedDay ? Colors.blue : Colors.black,
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
                          color:
                              isFocusedDay ? Colors.blue : Colors.transparent,
                        ),
                        margin: EdgeInsets.all(4),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                color:
                                    isFocusedDay ? Colors.white : Colors.black,
                                fontWeight: isFocusedDay
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Custom Layout', // Your custom content for the focused day
                              style: TextStyle(
                                color:
                                    isFocusedDay ? Colors.white : Colors.black,
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
            bottom: 20,
            right: 20,
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
                  Navigator.pushNamed(context, addNote);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out'),
            )
          ],
        );
      },
    ).then((value) => value ?? false);
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
            color: Color.fromARGB(255, 22, 53, 139),
            fontFamily: 'righteous'
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
            final timeColor = Colors.blue;
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
            );
          },
        ),
      ),
    ],
  );
}





  List<Event> getEventsForFocusedDay() {
    final eventsForFocusedDay = getEventsForDate(focusedDay);
    return eventsForFocusedDay;
  }
}
