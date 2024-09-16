import 'dart:developer' as devtools show log;

import 'package:first_project/models/recurrence_rule.dart';
import 'package:first_project/services/node_services/event_services.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:first_project/styles/widgets/repetition_dialog.dart';
import 'package:first_project/styles/widgets/view-item-styles/selected_user_widget.dart';
import 'package:first_project/utilities/color_manager.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
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
            : Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildColorPicker(context),
                    SizedBox(height: 10),
                    _buildTitleInput(context),
                    SizedBox(height: 10),
                    _buildDatePickers(context),
                    SizedBox(height: 10),
                    _buildLocationInput(context),
                    SizedBox(height: 10),
                    _buildDescriptionInput(context),
                    SizedBox(height: 10),
                    _buildNoteInput(context),
                    SizedBox(height: 20),
                    _buildRepetitionToggle(context),
                    SizedBox(height: 25),
                    _dialogButton(context),
                    SizedBox(height: 25),
                    _buildAddEventButton(context),
                  ],
                ),
              ),
      ),
    );
  }

  // Method to create a widget with padding and margins
// Method to create a widget with padding and margins
  Widget _buildAnimatedUsersListContainer() {
    return Container(
      padding: EdgeInsets.all(16.0), // Adjust padding as needed
      margin: EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 16.0), // Adjust margin as needed
      child: _selectedUsers.isEmpty
          ? Center(
              child: Text(
                'No users selected.',
                style: TextStyle(
                    color: Colors
                        .black), // Display message when no users are selected
              ),
            )
          : AnimatedUsersList(
              users: _selectedUsers), // Display the list if users are selected
    );
  }

  Widget _dialogButton(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0), // Adjust padding around the container
        margin: EdgeInsets.all(8.0), // Adjust margin around the container
        decoration: BoxDecoration(
          color: Colors.grey[200], // Background color of the container
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(2, 2), // Shadow position
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content
          children: [
            Text(
              'Click the button below to select users and view the list.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0), // Space between the text and button
            ElevatedButton(
              onPressed: () => _showUserSelectionDialog(context),
              child: Text('Show User Selection'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Button background color
                onPrimary: Colors.white, // Button text color
                padding: EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      8.0), // Rounded corners for the button
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildAnimatedUsersListContainer()
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.chooseEventColor,
          style: TextStyle(
              fontSize: 14, color: Color.fromARGB(255, 121, 122, 124)),
        ),
        DropdownButtonFormField<Color>(
          value: _selectedEventColor,
          onChanged: (color) {
            setState(() {
              _selectedEventColor = color!;
            });
          },
          items: _colorList.map((color) {
            String colorName = ColorManager.getColorName(color);
            return DropdownMenuItem<Color>(
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
        ),
      ],
    );
  }

  Widget _buildTitleInput(BuildContext context) {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.title(15),
      ),
      maxLength: 15,
    );
  }

  Widget _buildDatePickers(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: _buildDatePicker(context, true),
          ),
          SizedBox(width: 10),
          Flexible(
            flex: 1,
            child: _buildDatePicker(context, false),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, bool isStartDate) {
    String dateTitle = isStartDate
        ? AppLocalizations.of(context)!.startDate
        : AppLocalizations.of(context)!.endDate;
    DateTime selectedDate = isStartDate ? _selectedStartDate : _selectedEndDate;
    Color backgroundColor = isStartDate
        ? Color.fromARGB(255, 92, 206, 134)
        : Color.fromARGB(255, 223, 106, 106);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Text(
            dateTitle,
            style: TextStyle(fontSize: 15, color: Colors.black),
          ),
        ),
        SizedBox(height: 8.0),
        InkWell(
          onTap: () => _selectDate(context, isStartDate),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white),
              ),
              Text(
                DateFormat('hh:mm a').format(selectedDate),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 28, 58, 82)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInput(BuildContext context) {
    return TypeAheadField<String>(
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
        return ListTile(title: Text(suggestion));
      },
      onSuggestionSelected: (suggestion) {
        setState(() {
          _locationController.text = suggestion;
        });
      },
    );
  }

  void _showUserSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select users for this event'),
          content: Container(
            width: 300, // Set a fixed width for the dialog
            height: 250, // Set a fixed height for the dialog
            child: _buildUserSelection(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_users.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'No users available to select.',
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          )
        else
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      bottom: 16.0), // Space below the MultiSelectDialogField
                  child: MultiSelectDialogField<User>(
                    items: _users
                        .map((e) => MultiSelectItem<User>(e, e.userName))
                        .toList(),
                    listType: MultiSelectListType.CHIP,
                    title: Text('Select Users'),
                    selectedColor: Color.fromARGB(63, 27, 152, 81),
                    // selectedItemsTextStyle: TextStyle(
                    //     backgroundColor: Color.fromARGB(255, 231, 231, 231)),
                    onConfirm: (values) {
                      setState(() {
                        _selectedUsers = values;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionInput(BuildContext context) {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.description(100),
      ),
      maxLength: 100,
    );
  }

  Widget _buildNoteInput(BuildContext context) {
    return TextFormField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.note(50),
      ),
      maxLength: 50,
    );
  }

  Widget _buildRepetitionToggle(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.repetitionDetails,
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(width: 70),
        GestureDetector(
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
                child: Text(
                  isRepetitive ? 'ON' : 'OFF',
                  style: TextStyle(
                      color: isRepetitive
                          ? Color.fromARGB(255, 28, 86, 120)
                          : Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddEventButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (_titleController.text.isEmpty) {
            // Show an error message or handle the empty title here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please enter a title for the event.'),
              ),
            );
          } else {
            _addEvent();
            _reloadScreen();
          }
        },
        child: Text(AppLocalizations.of(context)!.addEvent),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(AppLocalizations.of(context)!.event),
  //     ),
  //     body: SingleChildScrollView(
  //       // Wrap the Scaffold with SingleChildScrollV
  //       // iew
  //       child: isLoading
  //           ? Center(child: CircularProgressIndicator())
  //           : Container(
  //               padding: EdgeInsets.all(16.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     AppLocalizations.of(context)!.chooseEventColor,
  //                     style: TextStyle(
  //                         fontSize: 14,
  //                         color: Color.fromARGB(255, 121, 122, 124)),
  //                   ),
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       DropdownButtonFormField<Color>(
  //                         value: _selectedEventColor,
  //                         onChanged: (color) {
  //                           setState(() {
  //                             _selectedEventColor = color!;
  //                           });
  //                         },
  //                         items: _colorList.map((color) {
  //                           String colorName = ColorManager.getColorName(
  //                               color); // Get the name of the color
  //                           return DropdownMenuItem<Color>(
  //                             value: color,
  //                             child: Row(
  //                               children: [
  //                                 Container(
  //                                   width: 20, // Adjust the width as needed
  //                                   height: 20, // Adjust the height as needed
  //                                   color:
  //                                       color, // Use the color as the background
  //                                 ),
  //                                 SizedBox(
  //                                     width:
  //                                         10), // Add spacing between color and name
  //                                 Text(colorName), // Display the color name
  //                               ],
  //                             ),
  //                           );
  //                         }).toList(),
  //                       ),
  //                     ],
  //                   ),
  //                   SizedBox(
  //                       height:
  //                           10), // Add spacing between the color picker and the title
  //                   // Title Input
  //                   Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       TextFormField(
  //                         controller: _titleController,
  //                         decoration: InputDecoration(
  //                           labelText: AppLocalizations.of(context)!.title(15),
  //                         ),
  //                         maxLength: 15,
  //                       ),
  //                       SizedBox(height: 10),
  //                     ],
  //                   ),

  //                   Container(
  //                     padding:
  //                         EdgeInsets.all(16.0), // Adjust the padding as needed
  //                     decoration: BoxDecoration(
  //                       color: Colors.blue, // Set your desired background color
  //                       borderRadius: BorderRadius.circular(
  //                           10.0), // Adjust the border radius as needed
  //                     ),
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Flexible(
  //                           flex: 1,
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             children: [
  //                               Container(
  //                                 padding: EdgeInsets.all(
  //                                     8.0), // Adjust the padding as needed
  //                                 decoration: BoxDecoration(
  //                                   color: Color.fromARGB(255, 92, 206,
  //                                       134), // Set the background color of the title
  //                                   borderRadius: BorderRadius.circular(
  //                                       5.0), // Adjust the border radius as needed
  //                                 ),
  //                                 child: Text(
  //                                   AppLocalizations.of(context)!.startDate,
  //                                   style: TextStyle(
  //                                       fontSize: 15, color: Colors.black),
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                   height: 8.0), // Add margin below the title
  //                               InkWell(
  //                                 onTap: () => _selectDate(context, true),
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.center,
  //                                   children: [
  //                                     Text(
  //                                       DateFormat('yyyy-MM-dd')
  //                                           .format(_selectedStartDate),
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 15,
  //                                         color: Colors.white,
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       DateFormat('hh:mm a')
  //                                           .format(_selectedStartDate),
  //                                       style: TextStyle(
  //                                         fontSize: 15,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: const Color.fromARGB(
  //                                             255, 28, 58, 82),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         SizedBox(width: 10),
  //                         Flexible(
  //                           flex: 1,
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Container(
  //                                 padding: EdgeInsets.all(
  //                                     8.0), // Adjust the padding as needed
  //                                 decoration: BoxDecoration(
  //                                   color: Color.fromARGB(255, 223, 106,
  //                                       106), // Set the background color of the title
  //                                   borderRadius: BorderRadius.circular(
  //                                       5.0), // Adjust the border radius as needed
  //                                 ),
  //                                 child: Text(
  //                                   AppLocalizations.of(context)!.endDate,
  //                                   style: TextStyle(
  //                                       fontSize: 15, color: Colors.black),
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                   height: 8.0), // Add margin below the title
  //                               InkWell(
  //                                 onTap: () => _selectDate(context, false),
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.center,
  //                                   children: [
  //                                     Text(
  //                                       DateFormat('yyyy-MM-dd')
  //                                           .format(_selectedEndDate),
  //                                       style: TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 15,
  //                                         color: Colors.white,
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       DateFormat('hh:mm a')
  //                                           .format(_selectedEndDate),
  //                                       style: TextStyle(
  //                                         fontSize: 15,
  //                                         fontWeight: FontWeight.bold,
  //                                         color: const Color.fromARGB(
  //                                             255, 28, 58, 82),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),

  //                   SizedBox(height: 10),
  //                   // Location Input
  //                   // Location Input with Auto-Completion
  //                   TypeAheadField<String>(
  //                     textFieldConfiguration: TextFieldConfiguration(
  //                       controller: _locationController,
  //                       decoration: InputDecoration(
  //                         labelText: AppLocalizations.of(context)!.location,
  //                       ),
  //                     ),
  //                     suggestionsCallback: (pattern) async {
  //                       return await Utilities.getAddressSuggestions(pattern);
  //                     },
  //                     itemBuilder: (context, suggestion) {
  //                       return ListTile(
  //                         title: Text(suggestion),
  //                       );
  //                     },
  //                     onSuggestionSelected: (suggestion) {
  //                       setState(() {
  //                         _locationController.text = suggestion;
  //                       });
  //                     },
  //                   ),

  //                   SizedBox(height: 10),

  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(vertical: 10.0),
  //                     child: Text(
  //                       'Please select a user from the list below and provide a description and note.',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         color: Colors.grey[700],
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ),

  //                   // Check if the users list is empty
  //                   if (_users.isEmpty)
  //                     Padding(
  //                       padding: const EdgeInsets.symmetric(vertical: 20.0),
  //                       child: Text(
  //                         'No users available to select.',
  //                         style: TextStyle(fontSize: 16, color: Colors.red),
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     )
  //                   else
  //                     Container(
  //                       decoration: BoxDecoration(),
  //                       child: Column(
  //                         // Wrap with a Column to allow multiple widgets inside
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           MultiSelectDialogField(
  //                             items: _users
  //                                 .map((e) => MultiSelectItem(e, e.userName))
  //                                 .toList(),
  //                             listType: MultiSelectListType.CHIP,
  //                             onConfirm: (values) {
  //                               setState(() {
  //                                 _selectedUsers =
  //                                     values; // Update _selectedUsers on selection
  //                               });
  //                             },
  //                           ),

  //                           SizedBox(
  //                               height:
  //                                   10), // Add some space between the dropdown and list

  //                           // Add the AnimatedUsersList here
  //                           AnimatedUsersList(
  //                             users:
  //                                 _selectedUsers, // Pass the updated selected users list
  //                             // listKey: _listKey, // Pass the GlobalKey
  //                           ),
  //                         ],
  //                       ),
  //                     ),

  //                   SizedBox(height: 10),

  //                   // Description Input
  //                   TextFormField(
  //                     controller: _descriptionController,
  //                     decoration: InputDecoration(
  //                       labelText:
  //                           AppLocalizations.of(context)!.description(100),
  //                     ),
  //                     maxLength: 100,
  //                   ),

  //                   SizedBox(height: 10),

  //                   // Note Input
  //                   TextFormField(
  //                     controller: _noteController,
  //                     decoration: InputDecoration(
  //                       labelText: AppLocalizations.of(context)!.note(50),
  //                     ),
  //                     maxLength: 50,
  //                   ),

  //                   SizedBox(height: 20),

  //                   //**Slide Button to Toggle Repetition */
  //                   Row(
  //                     children: [
  //                       Text(
  //                         AppLocalizations.of(context)!.repetitionDetails,
  //                         style: TextStyle(
  //                           fontSize: 15,
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         width:
  //                             70, // Increase the width to add more separation
  //                       ),
  //                       GestureDetector(
  //                         onTap: () async {
  //                           final List<dynamic>? result = await showDialog(
  //                             context: context,
  //                             builder: (BuildContext context) {
  //                               return RepetitionDialog(
  //                                   selectedStartDate: _selectedStartDate,
  //                                   selectedEndDate: _selectedEndDate,
  //                                   initialRecurrenceRule: _recurrenceRule);
  //                             },
  //                           );
  //                           if (result != null && result.isNotEmpty) {
  //                             bool updatedIsRepetitive = result[1];
  //                             RecurrenceRule? updatedRecurrenceRule = result[0];

  //                             // Update isRepetitive and recurrenceRule based on the values from the dialog
  //                             setState(() {
  //                               isRepetitive = updatedIsRepetitive;
  //                               if (updatedRecurrenceRule != null) {
  //                                 _recurrenceRule = updatedRecurrenceRule;
  //                               }
  //                             });
  //                           }
  //                         },
  //                         child: AnimatedContainer(
  //                           duration: Duration(milliseconds: 300),
  //                           width: 2 * toggleWidth,
  //                           height: 40.0,
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(20.0),
  //                             color: isRepetitive ? Colors.green : Colors.grey,
  //                           ),
  //                           child: Center(
  //                             child: AnimatedSwitcher(
  //                               duration: Duration(milliseconds: 300),
  //                               child: isRepetitive
  //                                   ? Text(
  //                                       'ON',
  //                                       style: TextStyle(
  //                                         color:
  //                                             Color.fromARGB(255, 28, 86, 120),
  //                                       ),
  //                                     )
  //                                   : Text(
  //                                       'OFF',
  //                                       style: TextStyle(
  //                                         color: Colors.white,
  //                                       ),
  //                                     ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),

  //                   // Repetition Dropdown (conditionally shown)
  //                   SizedBox(height: 25),
  //                   Center(
  //                     child: ElevatedButton(
  //                       onPressed: () {
  //                         if (_titleController.text.isEmpty) {
  //                           // Show an error message or handle the empty title here
  //                         } else {
  //                           _addEvent();
  //                           _reloadScreen();
  //                         }
  //                       },
  //                       child: Text(AppLocalizations.of(context)!.addEvent),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //     ),
  //   );
  // }
}
