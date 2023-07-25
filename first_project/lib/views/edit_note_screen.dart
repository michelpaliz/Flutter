import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';

//*
class EditNoteScreen extends StatefulWidget {
  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late Event event;
  TextEditingController _noteController = TextEditingController();

  /** This method is called when the dependencies of the widget change, */
  @override
  void didChangeDependencies() {
    //  it retrieves the Event object passed as an argument to the screen and assigns its note value to the _noteController to populate the TextField with the existing note.
    super.didChangeDependencies();
    event = ModalRoute.of(context)!.settings.arguments as Event;
    _noteController.text = event.note;
  }

  /**The dispose method is overridden to properly dispose of the _noteController when the screen is no longer needed, preventing memory leaks.*/
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  //** UI FOR THE VIEW */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Note'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveChanges();
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() async {
    final updatedNote = _noteController.text;
    final updatedEvent = Event(
      id: event.id,
      startDate: event.startDate,
      endDate: event.endDate,
      note: updatedNote,
    );

    try {
      await StoreService.firebase()
          .updateEvent(updatedEvent); // Call the updateEvent method

      Navigator.pop(context, updatedEvent);
    } catch (error) {
      // Handle the error
    }
  }
}
