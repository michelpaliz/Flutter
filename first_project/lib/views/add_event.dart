import 'dart:convert';

import 'package:first_project/costume_widgets/number_selector.dart';
import 'package:first_project/enums/days_week.dart';
import 'package:first_project/models/recurrence_rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http; // Import the http package
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
    Set<DayOfWeek> selectedDays = Set<DayOfWeek>();

    String previousFrequency = selectedFrequency;

    // Define the selectDay function to handle day selection
    void selectDay(DayOfWeek day) {
      setState(() {
        if (selectedDays.contains(day)) {
          selectedDays.remove(day);
        } else {
          selectedDays.add(day);
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Select Repetition'),
              content: SingleChildScrollView(
                // Add SingleChildScrollView here
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text('Select Frequency:',
                          style: TextStyle(fontSize: 14)),
                    ),
                    SizedBox(height: 8), // Add some spacing
                    Wrap(
                      children: ['Daily', 'Weekly', 'Monthly', 'Yearly']
                          .map((frequency) {
                        final isSelected = frequency == selectedFrequency;

                        // Reset the NumberSelector value when frequency changes
                        if (previousFrequency != selectedFrequency) {
                          repeatInterval =
                              0; // You may need to adjust this value based on your requirements
                          selectedMonth =
                              null; // Reset selectedMonth when frequency changes
                        }

                        previousFrequency = selectedFrequency;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFrequency =
                                  frequency; // Update the selected frequency
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isSelected
                                  ? Colors.blue
                                  : Color.fromARGB(255, 212, 234, 248),
                            ),
                            child: Text(
                              frequency,
                              style: TextStyle(
                                fontSize: 13, // Adjust the font size here
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Add the day selection row if selectedFrequency is 'Weekly'
                    if (selectedFrequency == 'Weekly')
                      Row(
                        children: [
                          Text(
                            'Repeat Every: ',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          NumberSelector(
                            value: repeatInterval,
                            minValue: 0,
                            maxValue: 18,
                            onChanged: (value) {
                              setState(() {
                                repeatInterval = value;
                              });
                            },
                          ),
                          Text(
                            ' ${selectedFrequency.toLowerCase()}(s)',
                            style: TextStyle(
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    // Add the day selection row if selectedFrequency is 'Weekly'
                    if (selectedFrequency != 'Daily' &&
                        selectedFrequency != 'Monthly' &&
                        selectedFrequency != 'Yearly')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text('Select Day:',
                                style: TextStyle(fontSize: 14)),
                          ),
                          SizedBox(height: 8), // Add some spacing
                          Wrap(
                            children: DayOfWeek.values.map((day) {
                              final isSelected = selectedDays.contains(
                                  day); // Check if the day is selected

                              // Define the tap handler to toggle day selection
                              void toggleDaySelection() {
                                setState(() {
                                  if (isSelected) {
                                    selectedDays.remove(day);
                                  } else {
                                    selectedDays.add(day);
                                  }
                                });
                              }

                              return GestureDetector(
                                onTap:
                                    toggleDaySelection, // Use the defined tap handler
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  margin: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? Colors.blue
                                        : const Color.fromARGB(
                                            255, 240, 239, 239),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    day.displayName.substring(0, 3),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    // Optional input for day of month (for Daily)
                    if (selectedFrequency == 'Daily')
                      Row(
                        children: [
                          Text(
                            'Repeat Every: ',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          NumberSelector(
                            value: repeatInterval,
                            minValue: 0,
                            maxValue: 500,
                            onChanged: (value) {
                              setState(() {
                                repeatInterval = value;
                              });
                            },
                          ),
                          Text(
                            ' ${selectedFrequency.toLowerCase()}(s)',
                            style: TextStyle(
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    // Optional input for day of month (for Monthly and Yearly)
                    Visibility(
                      visible: selectedFrequency == 'Monthly' ||
                          selectedFrequency == 'Yearly',
                      child: SizedBox(height: 8), // Add some spacing
                    ),
                    Visibility(
                      visible: selectedFrequency == 'Monthly' ||
                          selectedFrequency == 'Yearly',
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'Selected day: ${DateFormat('dd').format(_selectedStartDate)}', // Display the selected day or 'Not Selected'
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Add the 'Repeat Every' row if selectedFrequency is 'Monthly'
                    if (selectedFrequency == 'Monthly')
                      Row(
                        children: [
                          Text(
                            'Repeat Every: ',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          if (selectedFrequency != 'Daily' &&
                              selectedFrequency != 'Yearly')
                            NumberSelector(
                              value: repeatInterval,
                              minValue: 0,
                              maxValue: 18, // Adjust the max value for Monthly
                              onChanged: (value) {
                                setState(() {
                                  repeatInterval = value;
                                });
                              },
                            ),
                          Text(
                            ' ${selectedFrequency.toLowerCase()}(s)',
                            style: TextStyle(
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 8), // Add some spacing
                    // Add the 'Repeat Every' row if selectedFrequency is 'Yearly'
                    if (selectedFrequency == 'Yearly')
                      Row(
                        children: [
                          Text(
                            'Repeat Every: ',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          if (selectedFrequency != 'Daily')
                            NumberSelector(
                              value: repeatInterval,
                              minValue: 0,
                              maxValue: 10, // Adjust the max value for Yearly
                              onChanged: (value) {
                                setState(() {
                                  repeatInterval = value;
                                });
                              },
                            ),
                          Text(
                            ' ${selectedFrequency.toLowerCase()}(s)',
                            style: TextStyle(
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 8), // Add some spacing
                    // Row for "Repeats Forever" checkbox
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
                        Text('Repeats Forever', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    // Row for "Repeats Until" and date picker
                    Row(children: [
                      Checkbox(
                        value: !isForever,
                        onChanged: (bool? newValue) {
                          setState(() {
                            isForever = !(newValue ?? false);
                          });
                        },
                      ),
                      Text('Repeats Until: ', style: TextStyle(fontSize: 14)),
                      if (!isForever)
                        InkWell(
                          onTap: () async {
                            final selectedDate = await showDatePicker(
                              context: context,
                              initialDate: untilDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year +
                                  10), // Adjust the date range as needed
                            );

                            if (selectedDate != null) {
                              setState(() {
                                untilDate = selectedDate;
                              });
                            }
                          },
                          child: Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue, // Change the text color here
                              decoration: TextDecoration
                                  .underline, // Add underlining for a clickable look
                            ),
                          ),
                        ),
                    ]),
                    // Display the selected "Until Date"
                    if (!isForever)
                      Text(
                        untilDate == null
                            ? 'Until Date: Not Selected'
                            : 'Until Date: ${DateFormat('yyyy-MM-dd').format(untilDate!)}', // Format the date
                        style: TextStyle(fontSize: 14),
                      ),
                  ],
                ),
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
