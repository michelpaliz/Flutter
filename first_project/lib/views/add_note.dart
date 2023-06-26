import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../utiliies/sharedprefs.dart';
import '../utiliies/userUtils.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
    _eventController = TextEditingController();
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
  bool isStartDateUnique = eventList.every((e) => e.startDate != event.startDate);

  if (isStartDateUnique) {
    setState(() {
      eventList.add(event);
    });

    // Get the user object from preferences
    User? user = await getCurrentUser();

    if (user != null) {
      // Fetch the user's existing events and add the new event
      List<Event> userEvents = user.events ?? [];
      userEvents.add(event);

      // Update the user object with the updated events list
      user.events = userEvents;

      // Store the updated user object
      await SharedPrefsUtils.storeUser(user);

      // Get the user collection reference in Firestore
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');

      // Query the user collection for the document with a specific condition (e.g., matching user email)
      QuerySnapshot userQuerySnapshot = await userCollection
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        // Get the document reference of the first matching document
        DocumentReference userRef = userQuerySnapshot.docs.first.reference;

        // Update the user document with the updated events list
        await userRef.update({
          'events': userEvents.map((event) => event.toMap()).toList(),
        });

        // Display a success message
        // scaffoldKey.currentState?.showSnackBar(
        //   SnackBar(content: Text('User updated successfully!')),
        // );
      }
    }

    // Clear the text field
    _eventController.clear();
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate Start Date'),
          content: Text('An event with the same start date already exists.'),
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


  Future<void> _removeEvent(String eventId) async {
    setState(() {
      eventList.removeWhere((event) => event.id == eventId);
    });

    User? user = await getCurrentUser();

    // Get the user collection reference in Firestore
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection('users');

    // Query the user collection for the document with a specific condition (e.g., matching user email)
    QuerySnapshot userQuerySnapshot = await userCollection
        .where('email', isEqualTo: user?.email)
        .limit(1)
        .get();

    if (userQuerySnapshot.docs.isNotEmpty) {
      // Get the document reference of the first matching document
      DocumentReference userRef = userQuerySnapshot.docs.first.reference;

      // Update the user document with the updated event list
      await userRef.update({
        'events': eventList.map((event) => event.toMap()).toList(),
      });

      // Display a success message
      // scaffoldKey.currentState?.showSnackBar(
      //   SnackBar(content: Text('Event removed successfully!')),
      // );
    }
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
              onPressed: () {
                _removeEvent(eventId);
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
