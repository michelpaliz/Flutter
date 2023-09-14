import 'package:first_project/enums/days_week.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/event.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../services/firestore/implements/firestore_service.dart';
import '../styles/app_bar_styles.dart';
import '../utilities/sharedprefs.dart';
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
  final User? user;
  final Group? group;
  Event? event;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  late TextEditingController _eventController;
  List<Event> eventList = [];
  StoreService storeService = StoreService.firebase();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController =
      TextEditingController(); // Add the controller for the description
  TextEditingController _noteController =
      TextEditingController(); // Add the controller for the note
  TextEditingController _locationController = TextEditingController(); // Add t

  String? selectedRecurrenceRule; // Declare the selectedRecurrenceRule variable
  var selectedDayOfWeek;
  bool isRepetitive = false;
  bool? isAllDay = false;

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
    loadEvents(); // Load events from shared preferences or other source
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
  Future<void> loadEvents() async {
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
    loadEvents(); // Reload events from shared preferences
  }

  void _removeEvents(String eventId) async {
    if (user != null) {
      // Remove the event from the eventList
      setState(() {
        eventList.removeWhere((event) => event.id == eventId);
      });

      Navigator.of(context).pop();
    } else if (group != null) {
      setState(() {
        eventList.removeWhere((event) => event.id == eventId);
      });

      // Update the group's events list and store it
      group!.calendar.events = eventList;
      await storeService.updateGroup(group!);

      Navigator.of(context).pop();
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

          await SharedPrefsUtils.storeUser(user!);
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
                _removeEvents(eventId);
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

                // ... (other input fields)

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
