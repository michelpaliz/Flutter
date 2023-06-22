import 'dart:developer' as devtools show log;
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/routes.dart';
import '../enums/menu_action.dart';

class Event {
  final DateTime date;
  // Add other properties as needed

  Event({
    required this.date,
    // Initialize other properties as needed
  });
}

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  List<Event> eventsList = [
    Event(date: DateTime(2023, 6, 1)),
    Event(date: DateTime(2023, 6, 15)),
    // Add more events with different dates
  ];
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
      body: Container(
        child: TableCalendar(
          eventLoader: (date) {
            // Implement your logic to load events or notes for the specified date
            // Return a list of events/notes for the date
            return getEventsForDate(
                date); // Replace this with your implementation
          },
          firstDay: DateTime.utc(2023, 1, 1),
          focusedDay: DateTime.now(),
          lastDay: DateTime.utc(2023, 12, 31),
          // Add other customization options as needed
          // ...
        ),
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
    // Implement your logic to retrieve events or notes for the specified date
    // Return a list of events/notes for the date

    // Example implementation:
    // Filter the events based on the date and return the matching events
    final eventsForDate = eventsList.where((event) {
      return event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day;
    }).toList();

    return eventsForDate;
  }
}
