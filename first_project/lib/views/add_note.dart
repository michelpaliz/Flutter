import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/event.dart';
import '../models/user.dart';
import '../services/firestore/implements/firestore_service.dart';
import '../utiliies/sharedprefs.dart';

void main() {
  runApp(MaterialApp(
    home: EventNoteWidget(),
  ));
}

class EventNoteWidget extends StatefulWidget {
  @override
  _EventNoteWidgetState createState() => _EventNoteWidgetState();
}

class _EventNoteWidgetState extends State<EventNoteWidget> {
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late TextEditingController _eventController;
  List<Event> eventList = [];
  StoreService storeService = StoreService.firebase();

  @override
  void initState() {
    super.initState();
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
    _eventController = TextEditingController();
    loadEvents(); // Load events from shared preferences
  }

  Future<void> loadEvents() async {
    User? user = await SharedPrefsUtils.getUserFromPreferences();
    if (user != null) {
      setState(() {
        eventList = user.events ?? [];
      });
    }
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
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

// The _addEvent method is marked as async, and await is used to retrieve the user object from preferences. This allows you to await the Future<User?> result and access the actual user object. Then, you can update the user object with the new event list and other modifications.
  void _addEvent() async {
    String eventNote = _eventController.text;
    String eventId = Uuid().v4();
    Event event = Event(
      id: eventId,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      note: eventNote,
      groupId: null,
    );

    // Check if the start date already exists in the eventList
    // Check if the start hour already exists in the eventList
    bool isStartHourUnique =
        eventList.every((e) => e.startDate.hour != event.startDate.hour);

    if (isStartHourUnique) {
      setState(() {
        eventList.add(event);
      });

      User? user = await SharedPrefsUtils.getUserFromPreferences();

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
            content: Text('An event with the same start hour already exists.'),
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
  }

  // Modify the _showRemoveConfirmationDialog method to call removeEvent correctly
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
                List<Event> updatedEvents =
                    await storeService.removeEvent(eventId);
                setState(() {
                  eventList = updatedEvents;
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onPressed: _addEvent,
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
                    title: Text('Note: ${event.note}'),
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
    );
  }

  // Retrieving the User object from shared preferences
}
