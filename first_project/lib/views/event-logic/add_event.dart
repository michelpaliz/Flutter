import 'dart:developer' as devtools show log;

import 'package:first_project/models/recurrence_rule.dart';
import 'package:first_project/services/node_services/event_services.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:first_project/styles/widgets/repetition_dialog.dart';
import 'package:first_project/utilities/color_manager.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:first_project/views/event-logic/widgets/dialog/user_expandable_card.dart';
import 'package:first_project/views/event-logic/widgets/form/add_event_button_widget.dart';
import 'package:first_project/views/event-logic/widgets/form/color_picker_widget.dart';
import 'package:first_project/views/event-logic/widgets/form/date_picker_widget.dart';
import 'package:first_project/views/event-logic/widgets/form/description_input_widget.dart';
import 'package:first_project/views/event-logic/widgets/form/location_input_widget.dart';
import 'package:first_project/views/event-logic/widgets/form/note_input_widget.dart';
import 'package:first_project/views/event-logic/widgets/form/title_input_widget.dart';
import 'package:first_project/views/event-logic/widgets/repetition_toggle_widget.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../models/group.dart';
import '../../models/user.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
// import 'package:multi_select_flutter/util/multi_select_item.dart';
// import 'package:multi_select_flutter/util/multi_select_list_type.dart';

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
  TextEditingController _locationController = TextEditingController();
  final TextEditingController userCtrl =
      TextEditingController(); // Controller for CustomDropdown
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  //** LOGIC VARIABLES FOR THE VIEW */
  final double toggleWidth = 50.0; // Width of the toggle button (constant)
  var selectedDayOfWeek;
  late bool isRepetitive = false;
  late RecurrenceRule? _recurrenceRule = null;
  //We define the default colors for the event object
  late Color _selectedEventColor;
  final _colorList = ColorManager.eventColors;
  late UserManagement _userManagement;
  late GroupManagement _groupManagement;
  late NotificationManagement _notificationManagement;
  EventService _eventService = new EventService();
  User? _selectedUser; // This will hold the selected user
  List<User> _users = []; // This will hold the list of users
  List<User> _selectedUsers = [];
  UserService _userService = new UserService();
  late bool isLoading;

  //** LOGIC FOR THE VIEW */////////
  _EventNoteWidgetState({User? user, Group? group})
      : _user = user,
        _group = group {
    isLoading = true;
    _initialize();
  }

  Future<void> _initialize() async {
    _selectedEventColor = _colorList.last;
    if (_user != null) {
      // Initialize eventList based on user
      _eventList = _user!.events;
    } else if (_group != null) {
      // Initialize eventList based on group
      _eventList = _group!.calendar.events;
      if (_group!.userIds.isNotEmpty) {
        for (var userId in _group!.userIds) {
          User user = await _userService.getUserById(userId);
          _users.add(user);
        }
      }
    }

    // Once initialization is complete, hide the loading spinner
    setState(() {
      isLoading = false;
    });
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
    _userManagement = Provider.of<UserManagement>(context);
    _groupManagement = Provider.of<GroupManagement>(context);
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
    // Get the event title from the text controller
    String eventTitle = _titleController.text;

    // Clean up the location text by removing unwanted characters
    String extractedText =
        _locationController.value.text.replaceAll(RegExp(r'[┤├]'), '');

    List<String> _usersIds = [];

    //Fill up the user's id in the list for the selected uses
    for (var user in _selectedUsers) {
      _usersIds.add(user.id);
    }

    // Check if the event title is not empty
    if (eventTitle.trim().isNotEmpty) {
      // Create a new event object with the provided details
      Event newEvent = Event(
          id: Utilities.generateRandomId(10),
          startDate: _selectedStartDate,
          endDate: _selectedEndDate,
          title: _titleController.text,
          groupId: _group?.id,
          recurrenceRule: _recurrenceRule,
          localization: extractedText,
          allDay: event?.allDay ?? false,
          description: _descriptionController.text,
          eventColorIndex: ColorManager().getColorIndex(_selectedEventColor),
          recipients: _usersIds,
          ownerID: _user!.id);

      // Check if repetitive events are allowed in the group
      bool allowRepetitiveHours = _group!.repetitiveEvents;

      // Create an update information
      newEvent.addUpdate(_user!.id);

      // Log the new event details
      devtools.log("New Event: ${newEvent.startDate.toIso8601String()}");

      // Log the current event list before checking for duplicates
      devtools.log("Event list before checking: ${_eventList.toString()}");

      // Check if an event with the same start date and time already exists
      bool eventExists = false;
      if (allowRepetitiveHours && _eventList.isNotEmpty) {
        eventExists = _eventList.any((event) {
          return event.startDate.year == newEvent.startDate.year &&
              event.startDate.month == newEvent.startDate.month &&
              event.startDate.day == newEvent.startDate.day &&
              event.startDate.hour == newEvent.startDate.hour;
        });
      }

      // If a duplicate event exists, show a dialog and return
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

      // Try to add the new event using the event service
      bool eventAdded = await _eventService.createEvent(newEvent);

      // If the event was added successfully
      if (eventAdded) {
        Event fetchedEvent = _eventService.event;
        setState(() {
          _eventList.add(fetchedEvent);
          devtools.log("Updated Event List: ${_eventList.toString()}");
        });

        // Update the user's event list and show a success message
        if (_user != null) {
          _user!.events.add(fetchedEvent);
          await _userManagement.updateUser(_user!);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.eventCreated)),
          );
        }
        // Update the group's event list and show a success message
        else if (_group != null) {
          _group?.calendar.events.add(fetchedEvent);
          devtools.log("This is the group value: ${_group.toString()}");
          await _groupManagement.updateGroup(_group!, _userManagement,
              _notificationManagement, _group!.invitedUsers);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.eventAddedGroup)),
          );
        }

        // Clear the input fields
        _clearFields();
      }
      // If the event was not added, show an error dialog
      else {
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
    }
    // If the event title is empty, show an error message
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorEventNote)),
      );
    }

    // Reload the screen
    _reloadScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.event),
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ColorPickerWidget(
                      selectedEventColor: _selectedEventColor,
                      onColorChanged: (color) {
                        setState(() {
                          _selectedEventColor = color!;
                        });
                      },
                      colorList: _colorList,
                    ),
                    SizedBox(height: 10),
                    TitleInputWidget(titleController: _titleController),
                    SizedBox(height: 10),
                    DatePickersWidget(
                      startDate: _selectedStartDate,
                      endDate: _selectedEndDate,
                      onStartDateTap: () => _selectDate(context, true),
                      onEndDateTap: () => _selectDate(context, false),
                    ),
                    SizedBox(height: 10),
                    LocationInputWidget(
                        locationController: _locationController),
                    SizedBox(height: 10),
                    DescriptionInputWidget(
                        descriptionController: _descriptionController),
                    SizedBox(height: 10),
                    NoteInputWidget(noteController: _noteController),
                    SizedBox(height: 10),
                    RepetitionToggleWidget(
                      isRepetitive: isRepetitive,
                      toggleWidth: toggleWidth,
                      onTap: () async {
                        final List<dynamic>? result = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return RepetitionDialog(
                              selectedStartDate: _selectedStartDate,
                              selectedEndDate: _selectedEndDate,
                              initialRecurrenceRule: _recurrenceRule,
                            );
                          },
                        );
                        if (result != null && result.isNotEmpty) {
                          setState(() {
                            isRepetitive = result[1];
                            _recurrenceRule = result[0] ?? _recurrenceRule;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    // UserDropdownTrigger(usersAvailable: _users),
                    UserExpandableCard(usersAvailable: _users),
                    SizedBox(height: 25),
                    AddEventButtonWidget(
                      onAddEvent: () {
                        if (_titleController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Please enter a title for the event.'),
                            ),
                          );
                        } else {
                          _addEvent();
                          _reloadScreen();
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
