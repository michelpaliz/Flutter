import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/event.dart';
import '../models/user.dart';
import '../services/firestore/implements/firestore_service.dart';
import '../services/user/user_provider.dart';
import '../styles/app_bar_styles.dart';
import '../utilities/sharedprefs.dart';

void main() {
  runApp(MaterialApp(
    home: EventNoteApp(),
  ));
}

class EventNoteApp extends StatelessWidget {
  const EventNoteApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Note Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventNoteWidget(),
    );
  }
}

//---- NOTE WIDGET ----

class EventNoteWidget extends StatefulWidget {
  @override
  _EventNoteWidgetState createState() => _EventNoteWidgetState();
}

class _EventNoteWidgetState extends State<EventNoteWidget> {
  //late: Indicates that the variable will be initialized later before it is accessed or used.
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late TextEditingController _eventController;
  List<Event> eventList = [];
  StoreService storeService = StoreService.firebase();

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
    _eventController = TextEditingController();
    loadEvents(); // Load events from shared preferences
  }

/**
 * the userEvents list is obtained from the user object. Then, the list is reversed using .reversed and the last 100 events are taken using .take(100)
 */
  Future<void> loadEvents() async {
    User? user = await getCurrentUser();
    if (user != null) {
      List<Event>? userEvents = user.events;
      setState(() {
        eventList = userEvents.reversed.take(100).toList();
      });
    }
    // SharedPrefsUtils.storeUser(user!);
  }

  void _reloadScreen() {
    setState(() {
      // Reset the necessary state variables if needed
      _selectedStartDate = DateTime.now();
      _selectedEndDate = DateTime.now();
      _eventController.clear();
    });
    loadEvents(); // Reload events from shared preferences
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: isStartDate
            ? TimeOfDay.fromDateTime(_selectedStartDate)
            : TimeOfDay.fromDateTime(_selectedEndDate),
      );

      if (pickedTime != null) {
        setState(() {
          if (isStartDate) {
            _selectedStartDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          } else {
            _selectedEndDate = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          }
        });
      }
    }
  }

  /*** We retrieve the current user object. Then we can update the user object with the new event list and other modifications.*/
  void _addEvent() async {
    String eventNote = _eventController.text;
    String eventId = Uuid().v4();

    if (eventNote.trim().isNotEmpty) {
      Event event = Event(
        id: eventId,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        note: eventNote,
        groupId: null,
      );

      // Check if an event with the same start hour and day already exists in the eventList
      bool isStartHourUnique = eventList.every((e) =>
          e.startDate.hour != event.startDate.hour ||
          e.startDate.day != event.startDate.day);

      if (isStartHourUnique) {
        setState(() {
          eventList.add(event);
        });

        // User? user = await SharedPrefsUtils.getUserFromPreferences();
        User? user = await getCurrentUser();

        if (user != null) {
          List<Event> userEvents = user.events ?? [];
          userEvents.add(event);
          user.events = userEvents;

          await SharedPrefsUtils.storeUser(user);
          await storeService.updateUser(user);

          // Display a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event added successfully!')),
          );
        }

        _eventController.clear();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Duplicate Start Date'),
              content: Text(
                  'An event with the same start hour and day already exists.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event note cannot be empty!')),
      );
    }

    _reloadScreen();
  }

  
  void _showRemoveConfirmationDialog(String eventId) {
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
                await storeService.removeEvent(eventId);
                // Update the events for the user in Firestore
                User? user = await getCurrentUser();
                if (user != null) {
                  user.events =
                      eventList.where((event) => event.id != eventId).toList();
                  await storeService.updateUser(user);
                }
                // Remove the event from the eventList
                setState(() {
                  eventList.removeWhere((event) => event.id == eventId);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    _reloadScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: AppBarStyles.themeData,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Event Note Widget'),
          ),
          body: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    _selectDate(context, true);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 10),
                      Text(
                        'Start Date: ${_selectedStartDate.toString()}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    _selectDate(context, false);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 10),
                      Text(
                        'End Date: ${_selectedEndDate.toString()}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _eventController,
                  decoration: InputDecoration(
                    labelText: 'Event/Note',
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _addEvent();
                      _reloadScreen();
                    },
                    // onPressed: _addEvent,
                    child: Text('Add Event'),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Event List:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: eventList.length,
                    itemBuilder: (context, index) {
                      Event event = eventList[index];
                      return ListTile(
                        title: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: 'Note : '.toUpperCase(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Lato',
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: Color.fromARGB(255, 14, 103, 133)),
                              ),
                              TextSpan(
                                text: event.note,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'lato',
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: Text(
                            'Start: ${event.startDate.toString()}\nEnd: ${event.endDate.toString()}'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _showRemoveConfirmationDialog(event.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
