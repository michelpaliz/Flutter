import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/user/user_provider.dart';
import 'package:first_project/utiliies/sharedprefs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/routes.dart';
import '../enums/menu_action.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../services/firestore/implements/firestore_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => NotesViewState();
}

class NotesViewState extends State<NotesView> {
  List<Event>? eventsList;
  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();
  Stream<List<Event>> eventsStream = Stream.empty();
  StoreService storeService = StoreService.firebase();

  StreamController<List<Event>> eventsStreamController = StreamController<List<Event>>();

Future<void> _getEventsListFromUser() async {
  User? user = await getCurrentUser();
  eventsList = user?.events;
  SharedPrefsUtils.storeUser(user!);
  setState(() {});

  getEventsStream(user).listen((List<Event> events) {
    setState(() {
      eventsList = events;
    });
  });
}

@override
void initState() {
  super.initState();
  _getEventsListFromUser();
}

Stream<List<Event>> getEventsStream(User user) {
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  // Query the users collection based on the user's email
  Query query = usersCollection.where('email', isEqualTo: user.email);

  // Create a stream transformer to map the query snapshots to event lists
  StreamTransformer<QuerySnapshot, List<Event>> transformer =
      StreamTransformer.fromHandlers(handleData: (snapshot, sink) async {
    List<Event> events = [];
    if (snapshot.docs.isNotEmpty) {
      // Get the first document from the snapshot
      DocumentSnapshot userDoc = snapshot.docs.first;

      // Retrieve the events and groupId fields from the user document
      List<dynamic> eventIds = userDoc.get('events');
      String groupId = userDoc.get('groupId');

      // Query the events collection using the retrieved eventIds
      CollectionReference eventsCollection = FirebaseFirestore.instance.collection('events');
      Query eventsQuery = eventsCollection.where(FieldPath.documentId, whereIn: eventIds);

      Stream<QuerySnapshot> eventsSnapshotStream = eventsQuery.snapshots();
      await for (QuerySnapshot eventsSnapshot in eventsSnapshotStream) {
        events = [];
        eventsSnapshot.docs.forEach((eventDoc) {
          // Create an Event object directly from the event document data
          Event event = Event(
            id: eventDoc.id,
            // Populate other properties based on your document structure
            startDate: eventDoc['startDate'].toDate(),
            endDate: eventDoc['endDate'].toDate(),
            note: eventDoc['note'],
            groupId: groupId,
          );
          events.add(event);
        });

        sink.add(events);
      }
    } else {
      sink.add(events);
    }
  });

  // Return the transformed stream
  return query.snapshots().transform(transformer);
}

void _reloadScreen() {
  Navigator.of(context).pop();
  Navigator.of(context).pushReplacementNamed('/your_screen_name'); // Replace with your actual screen name
}

@override
void dispose() {
  eventsStreamController.close(); // Close the stream controller when it's no longer needed
  super.dispose();
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
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    // Implement the logic to remove the event
                    // _removeEvent(event);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
