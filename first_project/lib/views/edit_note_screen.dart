import 'package:first_project/costume_widgets/repetition_dialog.dart';
import 'package:first_project/models/recurrence_rule.dart';
import 'package:first_project/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/firestore/implements/firestore_service.dart';
import '../styles/app_bar_styles.dart';

//*
class EditNoteScreen extends StatefulWidget {
  final Event event;
  EditNoteScreen({required this.event});
  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  StoreService storeService = StoreService.firebase();
  late Event event;

//** LOGIC VARIABLES  */
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  // late TextEditingController _eventController;
  List<Event> eventList = [];
  //** CONTROLLERS  */
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;
  late TextEditingController _locationController;
  //** LOGIC VARIABLES FOR THE VIEW */
  final double toggleWidth = 50.0; // Width of the toggle button (constant)
  var selectedDayOfWeek;
  late bool _isRepetitive = false;
  bool? isAllDay = false;
  String selectedRepetition = 'Daily'; // Default repetition is daily
  late RecurrenceRule? _recurrenceRule = null;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with event attributes
    event = widget.event;
    _titleController = TextEditingController(text: event.title);
    _descriptionController =
        TextEditingController(text: event.description ?? '');
    _noteController = TextEditingController(text: event.note ?? '');
    _locationController = TextEditingController(text: event.localization ?? '');
    _recurrenceRule = event.recurrenceRule;
    _isRepetitive = event.recurrenceRule != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the 'Event' object passed as an argument to this screen
    event = ModalRoute.of(context)!.settings.arguments as Event;
    // Set the attributes of the retrieved  'Event' object;
    _noteController.text = event.title;
    _selectedStartDate = event.startDate;
    _selectedEndDate = event.endDate;
    _descriptionController.text = event.description!;
    _locationController.text = event.localization!;
    _recurrenceRule = event.recurrenceRule;
    _isRepetitive = event.recurrenceRule != null;
    // _isRepetitive = event.recurrenceRule != null;
  }

  /**The dispose method is overridden to properly dispose of the _noteController when the screen is no longer needed, preventing memory leaks.*/
  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveEditedEvent() async {
    // Retrieve updated values from controllers
    final updatedTitle = _titleController.text;
    final updatedDescription = _descriptionController.text;
    final updatedNote = _noteController.text;
    final updatedLocation = _locationController.text;
    final updatedRecurrenceRule = _recurrenceRule;

    // Create an updated event with the new values
    final updatedEvent = Event(
      id: event.id,
      startDate: event.startDate,
      endDate: event.endDate,
      title: updatedTitle,
      groupId: event.groupId,
      description: updatedDescription,
      note: updatedNote,
      localization: updatedLocation,
      recurrenceRule: updatedRecurrenceRule,
      // Add other attributes as needed
    );

    try {
      await storeService
          .updateEvent(updatedEvent); // Call the updateEvent method

      // You can handle success or navigate back to the previous screen
      Navigator.pop(context, updatedEvent);
    } catch (error) {
      // Handle the error
    }
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

  //** UI FOR THE VIEW */

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppBarStyles.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Event Note Widget'),
        ),
        body: SingleChildScrollView(
          // Wrap the Scaffold with SingleChildScrollView
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title (max 20 characters)',
                  ),
                  maxLength: 20,
                ),

                SizedBox(height: 10),

                Container(
                  padding: EdgeInsets.all(16.0), // Adjust the padding as needed
                  decoration: BoxDecoration(
                    color: Colors.blue, // Set your desired background color
                    borderRadius: BorderRadius.circular(
                        10.0), // Adjust the border radius as needed
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                  8.0), // Adjust the padding as needed
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 92, 206,
                                    134), // Set the background color of the title
                                borderRadius: BorderRadius.circular(
                                    5.0), // Adjust the border radius as needed
                              ),
                              child: Text(
                                'Start Date',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 8.0), // Add margin below the title
                            InkWell(
                              onTap: () => _selectDate(context, true),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(_selectedStartDate),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('hh:mm a')
                                        .format(_selectedStartDate),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromARGB(255, 28, 58, 82),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(
                                  8.0), // Adjust the padding as needed
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 223, 106,
                                    106), // Set the background color of the title
                                borderRadius: BorderRadius.circular(
                                    5.0), // Adjust the border radius as needed
                              ),
                              child: Text(
                                'End Date',
                                style: TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                            ),
                            SizedBox(height: 8.0), // Add margin below the title
                            InkWell(
                              onTap: () => _selectDate(context, false),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(_selectedEndDate),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('hh:mm a')
                                        .format(_selectedEndDate),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          const Color.fromARGB(255, 28, 58, 82),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),
                // Location Input
                // Location Input with Auto-Completion
                TypeAheadField<String>(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: 'Location',
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return await Utilities.getAddressSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      _locationController.text = suggestion;
                    });
                  },
                ),

                SizedBox(height: 10),

                // Description Input
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (max 100 characters)',
                  ),
                  maxLength: 100,
                ),

                SizedBox(height: 10),

                // Note Input
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (max 50 characters)',
                  ),
                  maxLength: 50,
                ),

                SizedBox(height: 20),

                //**Slide Button to Toggle Repetition */
                Row(
                  children: [
                    Text(
                      "Repetition for the event",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      width: 70, // Increase the width to add more separation
                    ),
                    GestureDetector(
                      onTap: () async {
                        final List<dynamic>? result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return RepetitionDialog(
                                selectedStartDate: _selectedStartDate,
                                initialRecurrenceRule: _recurrenceRule);
                          },
                        );
                        if (result != null && result.isNotEmpty) {
                          bool updatedIsRepetitive = result[1];
                          RecurrenceRule? updatedRecurrenceRule = result[0];

                          // Update isRepetitive and recurrenceRule based on the values from the dialog
                          setState(() {
                            _isRepetitive = updatedIsRepetitive;
                            if (updatedRecurrenceRule == null) {
                              _recurrenceRule = null;
                            } else {
                              _recurrenceRule = updatedRecurrenceRule;
                            }
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 2 * toggleWidth,
                        height: 40.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: _isRepetitive ? Colors.green : Colors.grey,
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: _isRepetitive
                                ? Text(
                                    'ON',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 28, 86, 120),
                                    ),
                                  )
                                : Text(
                                    'OFF',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Repetition Dropdown (conditionally shown)
                SizedBox(height: 85),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isEmpty) {
                        // Show an error message or handle the empty title here
                      } else {
                        _saveEditedEvent();
                      }
                    },
                    child: Text('Edit Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
