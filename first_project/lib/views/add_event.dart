import 'package:first_project/costume_widgets/color_manager.dart';
import 'package:first_project/costume_widgets/repetition_dialog.dart';
import 'package:first_project/models/recurrence_rule.dart';
import 'package:first_project/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../services/firestore/implements/firestore_service.dart';
import '../styles/app_bar_styles.dart';

class EventNoteWidget extends StatefulWidget {
  final User? user;
  final Group? group;

  EventNoteWidget({Key? key, this.user, this.group}) : super(key: key);

  @override
  _EventNoteWidgetState createState() =>
      _EventNoteWidgetState(user: user, group: group);
}

class _EventNoteWidgetState extends State<EventNoteWidget> {
  //** LOGIC VARIABLES  */
  final User? user;
  final Group? group;
  Event? event;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  // late TextEditingController _eventController;
  List<Event> eventList = [];
  //** CONTROLLERS  */
  StoreService storeService = StoreService.firebase();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController =
      TextEditingController(); // Add the controller for the description
  TextEditingController _noteController =
      TextEditingController(); // Add the controller for the note
  TextEditingController _locationController = TextEditingController(); // Add t
  //** LOGIC VARIABLES FOR THE VIEW */
  final double toggleWidth = 50.0; // Width of the toggle button (constant)
  var selectedDayOfWeek;
  late bool isRepetitive = false;
  bool? isAllDay = false;
  String selectedRepetition = 'Daily'; // Default repetition is daily
  late RecurrenceRule? recurrenceRule = null;
  //We define the default colors for the event object
  late Color selectedEventColor;
  final colorList = ColorManager.eventColors;

  //** LOGIC FOR THE VIEW */////////
  _EventNoteWidgetState({this.user, this.group}) {
    if (user != null) {
      // Initialize eventList based on user
      eventList = user!.events; // Example: user.events if User has events list
    } else if (group != null) {
      // Initialize eventList based on group
      eventList = group!
          .calendar.events; // Example: group.events if Group has events list
    }
    selectedEventColor = colorList.last;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _noteController.clear();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
    // _eventController = TextEditingController();
    _loadEvents(); // Load events from shared preferences or other source
  }

/**
 * the userEvents list is obtained from the user object. Then, the list is reversed using .reversed and the last 100 events are taken using .take(100)
 */
  Future<void> _loadEvents() async {
    setState(() {
      eventList = eventList.reversed.take(100).toList();
    });
    // SharedPrefsUtils.storeUser(user!);
  }

  void _reloadScreen() {
    setState(() {
      // Reset the necessary state variables if needed
      _selectedStartDate = DateTime.now();
      _selectedEndDate = DateTime.now();
      // _eventController.clear();
    });
    _loadEvents(); // Reload events from shared preferences
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
    String eventTitle = _titleController.text;
    String eventId = Uuid().v4();

    // Remove unwanted characters and formatting
    String extractedText =
        _locationController.value.text.replaceAll(RegExp(r'[┤├]'), '');

    if (eventTitle.trim().isNotEmpty) {
      Event newEvent = Event(
        id: eventId,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        title: _titleController.text,
        groupId: group?.id, // Set the groupId if adding to a group's events
        recurrenceRule: recurrenceRule,
        localization: extractedText,
        allDay: event?.allDay ?? false,
        note: _noteController.text,
        description: _descriptionController.text,
        eventColorIndex: ColorManager().getColorIndex(selectedEventColor),
      );

      bool isStartHourUnique = eventList.every((e) =>
          e.startDate.hour != newEvent.startDate.hour ||
          e.startDate.day != newEvent.startDate.day);

      if (isStartHourUnique) {
        setState(() {
          eventList.add(newEvent);
        });

        if (user != null) {
          List<Event> userEvents = user!.events;
          userEvents.add(newEvent);
          user!.events = userEvents;

          await storeService.updateUser(user!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event added successfully!')),
          );
        } else if (group != null) {
          List<Event> groupEvents = group!.calendar.events;
          groupEvents.add(newEvent);
          group?.calendar.events = groupEvents;

          await storeService.updateGroup(group!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Event added to group successfully!')),
          );
        }

        _clearFields();
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
                Text(
                  'Choose the color of the event:',
                  style: TextStyle(
                      fontSize: 14, color: Color.fromARGB(255, 121, 122, 124)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Color>(
                      value: selectedEventColor,
                      onChanged: (color) {
                        setState(() {
                          selectedEventColor = color!;
                        });
                      },
                      items: colorList.map((color) {
                        String colorName = ColorManager.getColorName(
                            color); // Get the name of the color
                        return DropdownMenuItem<Color>(
                          value: color,
                          child: Row(
                            children: [
                              Container(
                                width: 20, // Adjust the width as needed
                                height: 20, // Adjust the height as needed
                                color: color, // Use the color as the background
                              ),
                              SizedBox(
                                  width:
                                      10), // Add spacing between color and name
                              Text(colorName), // Display the color name
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(
                    height:
                        10), // Add spacing between the color picker and the title
                // Title Input
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title (max 15 characters)',
                      ),
                      maxLength: 15,
                    ),
                    SizedBox(height: 10),
                  ],
                ),

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
                                initialRecurrenceRule: recurrenceRule);
                          },
                        );
                        if (result != null && result.isNotEmpty) {
                          bool updatedIsRepetitive = result[1];
                          RecurrenceRule? updatedRecurrenceRule = result[0];

                          // Update isRepetitive and recurrenceRule based on the values from the dialog
                          setState(() {
                            isRepetitive = updatedIsRepetitive;
                            if (updatedRecurrenceRule != null) {
                              recurrenceRule = updatedRecurrenceRule;
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
                          color: isRepetitive ? Colors.green : Colors.grey,
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: isRepetitive
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
                SizedBox(height: 25),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isEmpty) {
                        // Show an error message or handle the empty title here
                      } else {
                        _addEvent();
                        _reloadScreen();
                      }
                    },
                    child: Text('Add Event'),
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
