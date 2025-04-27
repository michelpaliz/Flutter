import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/b-backend/auth/node_services/event_services.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/dialog/user_expandable_card.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/form/add_event_button_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/form/color_picker_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/form/date_picker_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/form/description_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/form/location_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/form/note_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/form/title_input_widget.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/widgets/repetition_toggle_widget.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/c-frontend/b-group-section/utils/event/repetition_dialog.dart';
import 'package:first_project/c-frontend/b-group-section/utils/event/color_manager.dart';
import 'package:first_project/f-themes/utilities/utilities.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../a-models/group_model/event_appointment/event/event.dart';
import '../../../../a-models/group_model/group/group.dart';
import '../../../../a-models/user_model/user.dart';

class AddEvent extends StatefulWidget {
  final Group group;

  AddEvent({Key? key, required this.group}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState(group: group);
}

class _AddEventState extends State<AddEvent> {
  //** LOGIC VARIABLES  */
  late User _user;
  Group _group;
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
  List<User> _users = []; // This will hold the list of users
  List<User> _selectedUsers = [];
  UserService _userService = new UserService();
  late bool isLoading;
  late Group fetchedUpdatedGroup;

  //** LOGIC FOR THE VIEW */////////
  _AddEventState({required Group group}) : _group = group {
    isLoading = true;
    _initialize();
  }

  Future<void> _initialize() async {
    _selectedEventColor = _colorList.last;

    // Initialize eventList based on group
    _eventList = _group.calendar.events;
    if (_group.userIds.isNotEmpty) {
      for (var userId in _group.userIds) {
        User user = await _userService.getUserById(userId);
        _users.add(user);
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
    _notificationManagement = Provider.of<NotificationManagement>(context);
    _userManagement = Provider.of<UserManagement>(context);
    _groupManagement = Provider.of<GroupManagement>(context);
    _user = _userManagement.user!;
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

  Future<void> _addEvent() async {
    try {
      // Get the event title from the text controller
      String eventTitle = _titleController.text.trim();

      // Clean up the location text by removing unwanted characters
      String extractedText =
          _locationController.text.replaceAll(RegExp(r'[┤├]'), '');

      // Ensure the title is not empty
      if (eventTitle.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorEventNote)),
        );
        return;
      }

      // Gather user IDs for the selected users
      List<String> _usersIds = _selectedUsers.map((user) => user.id).toList();

      // Create a new event object
      Event newEvent = Event(
        id: Utilities.generateRandomId(10),
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        title: eventTitle,
        groupId: _group.id,
        recurrenceRule: _recurrenceRule,
        localization: extractedText,
        allDay: event?.allDay ?? false,
        description: _descriptionController.text,
        eventColorIndex: ColorManager().getColorIndex(_selectedEventColor),
        recipients: _usersIds,
        ownerID: _user.id, // Ensure owner ID is valid
      );

      devtools
          .log("New Event Created: ${newEvent.startDate.toIso8601String()}");

      // Check for duplicate events if repetitive events are allowed
      bool eventExists = _eventList.any((existingEvent) {
        return existingEvent.startDate.year == newEvent.startDate.year &&
            existingEvent.startDate.month == newEvent.startDate.month &&
            existingEvent.startDate.day == newEvent.startDate.day &&
            existingEvent.startDate.hour == newEvent.startDate.hour;
      });

      if (eventExists) {
        _showRepetitionDialog();
        return;
      }

      // Attempt to add the new event through the event service
      bool eventAdded = await _eventService.createEvent(newEvent);

      if (eventAdded) {
        // Fetch and log the added event
        Event fetchedEvent = _eventService.event;
        devtools.log("Event added successfully: ${fetchedEvent.toString()}");

        // Update local state with the new event
        setState(() {
          _eventList.add(fetchedEvent);
          _user.events.add(fetchedEvent.id);
        });

        // Update the user's event list
        await _userManagement.updateUser(_user);

        // Update the group's event list and sync with group management
        _group.calendar.events.add(fetchedEvent);
        await _groupManagement.updateGroup(
          _group,
          _userManagement,
        );

        // Fetch the updated group
        fetchedUpdatedGroup =
            await _groupManagement.groupService.getGroupById(_group.id);

        _groupManagement.currentGroup = fetchedUpdatedGroup;

        // Show success messages
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.eventCreated)),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.eventAddedGroup)),
        );

        // Clear the form fields after successful event creation
        _clearFields();
      } else {
        // Show error dialog if event creation failed
        _showErrorDialog();
      }
    } catch (e) {
      // Log and handle any unexpected errors
      devtools.log("Error adding event: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneral)),
      // );
    }
  }

// Helper function to show repetition event warning dialog
  void _showRepetitionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.repetitionEvent),
          content: Text(AppLocalizations.of(context)!.repetitionEventInfo),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

// Helper function to show error dialog if event creation fails
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.event),
          content: Text(AppLocalizations.of(context)!.errorEventCreation),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // When the user presses the system back button, pass the updated group
        // await _addEvent();
        // Navigator.pop(context, fetchedUpdatedGroup);
        return true; // Prevents the default back action, since we handle it
      },
      child: Scaffold(
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
                      UserExpandableCard(usersAvailable: _users),
                      SizedBox(height: 25),
                      AddEventButtonWidget(
                        onAddEvent: () async {
                          if (_titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Please enter a title for the event.'),
                              ),
                            );
                          } else {
                            await _addEvent();
                            // Pop with the updated group after adding the event
                            Navigator.pop(context, fetchedUpdatedGroup);
                          }
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
