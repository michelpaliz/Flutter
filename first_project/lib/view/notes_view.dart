import 'dart:developer' as devtools show log;

import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/routes.dart';
import '../enums/menu_action.dart';
import '../models/event.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  List<Event> eventsList = [
    Event(date: DateTime(2023, 6, 1), note: "Note 1"),
    Event(date: DateTime(2023, 6, 15), note: "Note 2"),
  ];

  DateTime? selectedDate;

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
          )
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            eventLoader: (date) {
              return getEventsForDate(date); //
            },
            firstDay: DateTime.utc(2023, 1, 1),
            focusedDay: DateTime.now(),
            lastDay: DateTime.utc(2023, 12, 31),
            // Add other customization options as needed
            calendarBuilders: CalendarBuilders(
              // Customize the day cell appearance
              defaultBuilder: (context, date, _) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(date.day.toString()), // Display the day
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selectedDate != null)
            // Expanded(...): This widget is used to make the container take up the available vertical space. It allows the container to expand and occupy the remaining space below the calendar.
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    // The selectedDate! syntax is known as the null assertion operator (!). It is used to assert that a value is not null.
                    getNotesForDate(selectedDate!),
                    style: TextStyle(fontSize: 18),
                  ),
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

  /**this method filters a list of events (eventsList) to find only those events that match the year, month, and day of the provided date. It returns a new list (eventsForDate) containing the filtered events. */
  List<Event> getEventsForDate(DateTime date) {
    // The where method filters the list based on a condition defined by the provided anonymous function.
    final eventsForDate = eventsList.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();

    return eventsForDate;
  }

  /**This method retrieves the events or notes for the specified date, extracts the notes from the events, and concatenates them into a single string with each note separated by a newline character. */
  String getNotesForDate(DateTime date) {
    // Retrieve notes for the specified date
    final eventsForDate = getEventsForDate(date);

    // Concatenate the notes into a single string
    return eventsForDate.map((event) => event.note).join('\n');
  }
}
