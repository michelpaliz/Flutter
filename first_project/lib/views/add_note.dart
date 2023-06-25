import 'package:flutter/material.dart';

class EventNoteWidget extends StatefulWidget {
  @override
  _EventNoteWidgetState createState() => _EventNoteWidgetState();
}

class _EventNoteWidgetState extends State<EventNoteWidget> {
  late DateTime _selectedDateTime;
  late TextEditingController _eventController;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
    _eventController = TextEditingController();
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addEvent() {
    String dateTime = _selectedDateTime.toString();
    String event = _eventController.text;

    // Perform your logic to add the event

    // Clear the text field
    _eventController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Note Widget'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                _selectDate(context);
              },
              child: Row(
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 10),
                  Text(
                    _selectedDateTime.toString(),
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _eventController,
              decoration: InputDecoration(
                labelText: 'Event/Note',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addEvent,
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: EventNoteWidget(),
  ));
}
