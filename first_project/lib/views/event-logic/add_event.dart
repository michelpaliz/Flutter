import 'dart:developer' as devtools show log;

import 'package:first_project/models/recurrence_rule.dart';
import 'package:first_project/services/node_services/event_services.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/styles/widgets/repetition_dialog.dart';
import 'package:first_project/utilities/color_manager.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../models/group.dart';
import '../../models/user.dart';

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
  User? _user;
  Group? _group;
  Event? event;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  List<Event> _eventList = [];
  //** CONTROLLERS  */
  // late FirestoreService _storeService;
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
  late RecurrenceRule? _recurrenceRule = null;
  //We define the default colors for the event object
  late Color _selectedEventColor;
  final _colorList = ColorManager.eventColors;
  late ProviderManagement _providerManagement;
  EventService _eventService = new EventService();

  //** LOGIC FOR THE VIEW */////////
  _EventNoteWidgetState({User? user, Group? group})
      : _user = user,
        _group = group {
    if (_user != null) {
      // Initialize eventList based on user
      _user = user;
      _eventList = _user!.events;
    } else if (_group != null) {
      // Initialize eventList based on group
      _group = group;
      _eventList = _group!.calendar.events;
    }
    _selectedEventColor = _colorList.last;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
    _loadEvents(); // Load events from shared preferences or other source
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _providerManagement = Provider.of<ProviderManagement>(context);
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

/**
 * the userEvents list is obtained from the user object. Then, the list is reversed using .reversed and the last 100 events are taken using .take(100)
 */
  Future<void> _loadEvents() async {
    setState(() {
      _eventList = _eventList.reversed.take(100).toList();
    });
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
          // Combine the selected date and time
          DateTime newDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );

          // Use the intl package to handle the time zone correctly
          final localTimeZone =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(newDateTime);
          newDateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').parse(localTimeZone, true);

          // Add debug print statements
          print("Selected Date: $pickedDate");
          print("Selected Time: $pickedTime");
          print("Combined DateTime: $newDateTime");

          if (isStartDate) {
            _selectedStartDate = newDateTime;
          } else {
            _selectedEndDate = newDateTime;
          }
        });
      }
    }
  }

  void _addEvent() async {
    String eventTitle = _titleController.text;

    // Remove unwanted characters and formatting
    String extractedText =
        _locationController.value.text.replaceAll(RegExp(r'[┤├]'), '');

    String uniqueId = Utilities.generateRandomId(10);

    if (eventTitle.trim().isNotEmpty) {
      Event newEvent = Event(
        id: uniqueId,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        title: _titleController.text,
        groupId: _group?.id,
        recurrenceRule: _recurrenceRule,
        localization: extractedText,
        allDay: event?.allDay ?? false,
        description: _descriptionController.text,
        eventColorIndex: ColorManager().getColorIndex(_selectedEventColor),
      );

      bool allowRepetitiveHours = _group!.repetitiveEvents;
      // Log new event details
      devtools.log("New Event: ${newEvent.startDate.toIso8601String()}");

      // Log the event list before checking
      devtools.log("Event list before checking: ${_eventList.toString()}");

      bool eventExists = false;
      if (allowRepetitiveHours && _eventList.isNotEmpty) {
        eventExists = _eventList.any((event) {
          // Compare the events' start dates only if the event is on the same day as the new event
          return event.startDate.year == newEvent.startDate.year &&
              event.startDate.month == newEvent.startDate.month &&
              event.startDate.day == newEvent.startDate.day &&
              event.startDate.hour == newEvent.startDate.hour;
        });
      }

      if (eventExists) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.repetitionEvent),
              content: Text(AppLocalizations.of(context)!.repetitionEventInfo),
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
        return;
      }

      bool eventAdded = await _eventService.createEvent(newEvent);

      if (eventAdded) {
        Event fetchedEvent = _eventService.event;
        setState(() {
          _eventList.add(fetchedEvent);
          devtools.log("Updated Event List: ${_eventList.toString()}");
        });

        if (_user != null) {
          _user!.events.add(fetchedEvent);
          await _providerManagement.updateUser(_user!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.eventCreated)),
          );
        } else if (_group != null) {
          _group?.calendar.events.add(fetchedEvent);
          devtools.log("This is the group value: ${_group.toString()}");
          await _providerManagement.updateGroup(_group!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.eventAddedGroup)),
          );
        }

        _clearFields();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.event),
              content: Text(AppLocalizations.of(context)!.errorEventCreation),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.errorEventNote)),
      );
    }

    _reloadScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.event),
      ),
      body: SingleChildScrollView(
        // Wrap the Scaffold with SingleChildScrollV
        // iew
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.chooseEventColor,
                style: TextStyle(
                    fontSize: 14, color: Color.fromARGB(255, 121, 122, 124)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Color>(
                    value: _selectedEventColor,
                    onChanged: (color) {
                      setState(() {
                        _selectedEventColor = color!;
                      });
                    },
                    items: _colorList.map((color) {
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
                      labelText: AppLocalizations.of(context)!.title(15),
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
                              AppLocalizations.of(context)!.startDate,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
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
                              AppLocalizations.of(context)!.endDate,
                              style:
                                  TextStyle(fontSize: 15, color: Colors.black),
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
                    labelText: AppLocalizations.of(context)!.location,
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
                  labelText: AppLocalizations.of(context)!.description(100),
                ),
                maxLength: 100,
              ),

              SizedBox(height: 10),

              // Note Input
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.note(50),
                ),
                maxLength: 50,
              ),

              SizedBox(height: 20),

              //**Slide Button to Toggle Repetition */
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.repetitionDetails,
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
                              selectedEndDate: _selectedEndDate,
                              initialRecurrenceRule: _recurrenceRule);
                        },
                      );
                      if (result != null && result.isNotEmpty) {
                        bool updatedIsRepetitive = result[1];
                        RecurrenceRule? updatedRecurrenceRule = result[0];

                        // Update isRepetitive and recurrenceRule based on the values from the dialog
                        setState(() {
                          isRepetitive = updatedIsRepetitive;
                          if (updatedRecurrenceRule != null) {
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
                  child: Text(AppLocalizations.of(context)!.addEvent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
