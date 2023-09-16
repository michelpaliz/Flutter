import 'package:first_project/models/recurrence_rule.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/event.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../services/firestore/implements/firestore_service.dart';
import '../styles/app_bar_styles.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
  late TextEditingController _eventController;
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
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
    _eventController = TextEditingController();
    _loadEvents(); // Load events from shared preferences or other source
  }

  Future<List<String>> _getAddressSuggestions(String pattern) async {
    final baseUrl = Uri.parse('https://nominatim.openstreetmap.org/search');
    final queryParameters = {
      'format': 'json',
      'q': pattern,
    };

    final response =
        await http.get(baseUrl.replace(queryParameters: queryParameters));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      final suggestions =
          data.map((item) => item['display_name'] as String).toList();
      return suggestions;
    } else {
      throw Exception('Failed to load suggestions');
    }
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
      _eventController.clear();
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

  void _showRepetitionDialog(BuildContext context) {
    // Local state variables to store user input
    String selectedFrequency = 'Daily'; // Default to Daily
    int? repeatInterval;
    int? dayOfMonth;
    int? selectedMonth;
    bool isForever =
        false; // Variable to track whether the recurrence is forever
    DateTime? untilDate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Repetition'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Dropdown for selecting frequency
                  DropdownButton<String>(
                    value: selectedFrequency,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFrequency = newValue!;
                      });
                    },
                    items: <String>[
                      'Daily',
                      'Weekly',
                      'Monthly',
                      'Yearly',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),

                  // Optional input for repeat interval
                  if (selectedFrequency != 'Daily')
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Repeat every'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        repeatInterval = int.tryParse(value);
                      },
                    ),

                  // Optional input for day of month (for Monthly and Yearly)
                  if (selectedFrequency == 'Monthly' ||
                      selectedFrequency == 'Yearly')
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Day of Month'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        dayOfMonth = int.tryParse(value);
                      },
                    ),

                  // Dropdown for selecting the month (for Yearly)
                  if (selectedFrequency == 'Yearly')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: 15.0,
                              bottom: 5.0), // Add padding to the bottom
                          child: Text(
                            'Select the specific month of the year:',
                            style: TextStyle(
                              // You can also apply styling if needed
                              fontSize: 15.0,
                            ),
                          ),
                        ),
                        DropdownButton<int>(
                          value: selectedMonth,
                          onChanged: (int? newValue) {
                            setState(() {
                              selectedMonth = newValue;
                            });
                          },
                          items: List<DropdownMenuItem<int>>.generate(
                            12,
                            (index) => DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text('${index + 1}'),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // Checkbox to enable the "Forever" option for until date
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: isForever,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isForever = newValue ?? false;
                            if (isForever) {
                              untilDate =
                                  null; // If forever is selected, clear the until date
                            }
                          });
                        },
                      ),
                      Text('Forever'), // Label for the "Forever" checkbox
                    ],
                  ),

                  // Optional input for until date (disabled if "Forever" is selected)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Until Date (YYYY-MM-DD)',
                      enabled: !isForever, // Disable if "Forever" is selected
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (value) {
                      untilDate = DateTime.tryParse(value);
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Create a RecurrenceRule based on user input
                    RecurrenceRule recurrenceRule;

                    switch (selectedFrequency) {
                      case 'Daily':
                        recurrenceRule = RecurrenceRule.daily(
                          repeatInterval: repeatInterval,
                          untilDate: isForever
                              ? null
                              : untilDate, // Check if "Forever" is selected
                        );
                        break;
                      case 'Weekly':
                        recurrenceRule = RecurrenceRule.weekly(
                          null, // You can add logic here to select a day of the week
                          repeatInterval: repeatInterval,
                          untilDate: isForever
                              ? null
                              : untilDate, // Check if "Forever" is selected
                        );
                        break;
                      case 'Monthly':
                        recurrenceRule = RecurrenceRule.monthly(
                          dayOfMonth: dayOfMonth,
                          repeatInterval: repeatInterval,
                          untilDate: isForever
                              ? null
                              : untilDate, // Check if "Forever" is selected
                        );
                        break;
                      case 'Yearly':
                        recurrenceRule = RecurrenceRule.yearly(
                          month:
                              selectedMonth, // Provide the selected month here
                          dayOfMonth: dayOfMonth,
                          repeatInterval: repeatInterval,
                          untilDate: isForever
                              ? null
                              : untilDate, // Check if "Forever" is selected
                        );
                        break;
                      default:
                        recurrenceRule =
                            RecurrenceRule.daily(); // Default to Daily
                    }

                    // Now you can use recurrenceRule as needed (e.g., store it or apply it to an Event object)

                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /*** We retrieve the current user object. Then we can update the user object with the new event list and other modifications.*/
  void _addEvent() async {
    String eventNote = _eventController.text;
    String eventId = Uuid().v4();

    if (eventNote.trim().isNotEmpty) {
      Event newEvent = Event(
        id: eventId,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        title: eventNote,
        groupId: group?.id, // Set the groupId if adding to a group's events
        recurrenceRule:
            event?.recurrenceRule, // Retains recurrenceRule if available
        localization: event?.localization, // Retains localization if available
        allDay: event?.allDay ?? false, // Retains allDay with a default value
        note: event?.note, // Retains note if available
        description: event?.description, // Retains description if available
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
                    labelText: 'Title (max 10 characters)',
                  ),
                  maxLength: 10,
                ),

                SizedBox(height: 10),

                // Start Date and End Date Inputs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        onTap: () => _selectDate(context, true),
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                        ),
                        controller: TextEditingController(
                          text: _selectedStartDate.toString(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Flexible(
                      flex: 1,
                      child: TextFormField(
                        onTap: () => _selectDate(context, false),
                        decoration: InputDecoration(
                          labelText: 'End Date',
                        ),
                        controller: TextEditingController(
                          text: _selectedEndDate.toString(),
                        ),
                      ),
                    ),
                  ],
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
                    return await _getAddressSuggestions(pattern);
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
                    labelText: 'Description (max 30 characters)',
                  ),
                  maxLength: 30,
                ),

                SizedBox(height: 10),

                // Note Input
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (max 15 characters)',
                  ),
                  maxLength: 15,
                ),

                SizedBox(height: 10),

                //**Slide Button to Toggle Repetition */
                SizedBox(height: 10),
                Text(
                  "Repetition for the event",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    _showRepetitionDialog(
                        context); // Open the repetition selection dialog
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: 2 *
                        toggleWidth, // Twice the toggle width for slide effect
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

                // Repetition Dropdown (conditionally shown)
                if (isRepetitive)
                  Column(
                    children: [
                      SizedBox(height: 10),
                      DropdownButton<String>(
                        value: selectedRepetition,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedRepetition = newValue!;
                          });
                        },
                        items: <String>[
                          'daily',
                          'weekly',
                          'monthly',
                          'yearly',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                SizedBox(height: 10),
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
