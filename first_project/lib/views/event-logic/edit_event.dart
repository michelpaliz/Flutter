import 'package:first_project/models/group.dart';
import 'package:first_project/models/recurrence_rule.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/node_services/event_services.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:first_project/styles/widgets/repetition_dialog.dart';
import 'package:first_project/utilities/color_manager.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';

//*
class EditNoteScreen extends StatefulWidget {
  final Event event;
  EditNoteScreen({required this.event});
  @override
  _EditNoteScreenState createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
//** LOGIC VARIABLES  */
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  List<Event> _eventList = [];
  late Event _event;
  //** CONTROLLERS  */
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;
  late TextEditingController _locationController;
  //** LOGIC VARIABLES FOR THE VIEW */
  final double _toggleWidth = 50.0;
  var selectedDayOfWeek;
  late bool _isRepetitive;
  bool? isAllDay = false;
  late RecurrenceRule? _recurrenceRule = null;
  late Color _selectedEventColor;
  late List<Color> _colorList;
  late Group _group;
  // late FirestoreService _storeService;
  late UserManagement _userManagement;
  late GroupManagement _groupManagement;
  late EventService _eventService;
  User? _selectedUser;
  List<User> _users = []; // This will hold the list of users
  late String _informativeText;
  UserService _userService = new UserService();
  String? _currentUserName;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with event attributes
    _event = widget.event;
    _titleController = TextEditingController(text: _event.title);
    _noteController = TextEditingController(text: _event.note);
    _descriptionController =
        TextEditingController(text: _event.description ?? '');
    _locationController =
        TextEditingController(text: _event.localization ?? '');
    _recurrenceRule = _event.recurrenceRule;
    _isRepetitive = _event.recurrenceRule != null;
    _colorList = ColorManager.eventColors;
    _selectedEventColor = _colorList[_event.eventColorIndex];
    _eventService = new EventService();
    _informativeText = _event.updatedByText ?? "";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Access the inherited widget in the didChangeDependencies method.
    _userManagement = Provider.of<UserManagement>(context);
    _groupManagement = Provider.of<GroupManagement>(context);
    _event = ModalRoute.of(context)!.settings.arguments as Event;
    _noteController.text = _event.note ?? '';
    _selectedStartDate = _event.startDate;
    _selectedEndDate = _event.endDate;
    _descriptionController.text = _event.description!;
    _locationController.text = _event.localization!;
    _recurrenceRule = _event.recurrenceRule;
    _isRepetitive = _event.recurrenceRule != null;
    _group = _groupManagement.currentGroup!;
    _eventList = _userManagement.currentUser!.events;
    _currentUserName = _userManagement.currentUser?.name;
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    if (_group.userIds.isNotEmpty) {
      for (var userId in _group.userIds) {
        User user = await _userService.getUserById(userId);
        setState(() {
          _users.add(user);
          // Initialize _selectedUser if it matches the event's user ID
          if (_event.recipient == user.id) {
            _selectedUser = user;
          }
        });
      }
    }
  }

  /**The dispose method is overridden to properly dispose of the _noteController when the screen is no longer needed, preventing memory leaks.*/
  @override
  void dispose() {
    // _noteController.dispose();
    super.dispose();
  }

  void _saveEditedEvent() async {
    // Retrieve updated values from controllers
    final updatedTitle = _titleController.text;
    final updatedDescription = _descriptionController.text;
    final updatedLocation = _locationController.text;
    final updatedRecurrenceRule = _recurrenceRule;
    final updatedNote = _noteController.text;

    String extractedText = updatedLocation;
    // Remove unwanted characters and formatting
    extractedText = extractedText.replaceAll(RegExp(r'[┤├]'), '');

    String updatedInf = "Last update was by ${_currentUserName}";

    // Create an updated event with the new values
    final updatedEvent = Event(
      id: _event.id,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      title: updatedTitle,
      groupId: _event.groupId,
      description: updatedDescription,
      note: updatedNote,
      localization: extractedText,
      recurrenceRule: updatedRecurrenceRule,
      eventColorIndex: ColorManager().getColorIndex(_selectedEventColor),
      recipient: _selectedUser?.id,
      updatedByText: updatedInf,
    );

    // Get the group and event list
    _eventList = _group.calendar.events;

    // Check if the start date has changed
    bool startDateChanged = _event.startDate != _selectedStartDate;

    bool allowRepetitiveHours = _group.repetitiveEvents;

    bool isStartHourUnique = true;

    if (allowRepetitiveHours) {
      // Extract the date part for comparison
      DateTime startDateOnly = DateTime(_selectedStartDate.year,
          _selectedStartDate.month, _selectedStartDate.day);

      isStartHourUnique = _eventList.every((e) {
        DateTime eventStartDateOnly =
            DateTime(e.startDate.year, e.startDate.month, e.startDate.day);

        // Allow the current event's start date if it hasn't changed
        if (!startDateChanged && e.id == _event.id) {
          return true;
        }

        // Ensure unique start dates for other events on the same day if the start date has changed
        return eventStartDateOnly != startDateOnly;
      });
    }

    if (isStartHourUnique || !allowRepetitiveHours) {
      try {
        await _eventService.updateEvent(updatedEvent.id, updatedEvent);
        // Handle success or navigate back to the previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.eventEdited)),
        );

        // Fetch the updated group
        _group = await _groupManagement.groupService.getGroupById(_group.id);
        // Update the group with the new list of events
        _groupManagement.currentGroup = _group;
        // Navigator.pop(context, updatedEvent);
      } catch (error) {
        // Handle the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.eventEditFailed)),
        );
      }
    } else {
      // Show alert dialog if conditions are not met
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

  //** UI FOR THE VIEW */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.event),
      ),
      body: SingleChildScrollView(
        // Wrap the Scaffold with SingleChildScrollView
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
                      String colorName = ColorManager.getColorName(color);
                      String key = color.hashCode.toString();
                      return DropdownMenuItem<Color>(
                        key: ValueKey<String>(
                            key), // Use a unique key for each item
                        value: color,
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              color: color,
                            ),
                            SizedBox(width: 10),
                            Text(colorName),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
              // Title Input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title(15),
                ),
                maxLength: 15,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Please select a user from the list below and provide a description and note.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              DropdownButtonFormField<User>(
                value: _selectedUser,
                onChanged: (User? newValue) {
                  setState(() {
                    _selectedUser = newValue;
                  });
                },
                items: _users.map<DropdownMenuItem<User>>((User user) {
                  return DropdownMenuItem<User>(
                    value: user,
                    child: Text(user
                        .name), // Assuming the User class has a name property
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select User',
                ),
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
                      width: 2 * _toggleWidth,
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

              SizedBox(height: 15),
              if (_informativeText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    _informativeText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Repetition Dropdown (conditionally shown)
              SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isEmpty) {
                      // Show an error message or handle the empty title here
                    } else {
                      _saveEditedEvent();
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.edit),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
