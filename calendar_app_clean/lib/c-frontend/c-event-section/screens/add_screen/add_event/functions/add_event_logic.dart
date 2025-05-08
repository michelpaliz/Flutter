import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import '../../../../../../a-models/group_model/event_appointment/event/event.dart';
import '../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../a-models/user_model/user.dart';
import '../../../../../../b-backend/api/event/event_services.dart';
import '../../../../../../b-backend/api/user/user_services.dart';
import '../../../../../../d-stateManagement/group_management.dart';
import '../../../../../../d-stateManagement/notification_management.dart';
import '../../../../../../d-stateManagement/user_management.dart';
import '../../../../../../f-themes/utilities/utilities.dart';
import '../../../../utils/event/color_manager.dart';
import '../functions/add_event_dialogs.dart';

mixin AddEventLogic<T extends StatefulWidget> on State<T>
    implements AddEventDialogs {
  // Core services
  late UserManagement userManagement;
  late GroupManagement groupManagement;
  late NotificationManagement notificationManagement;
  final EventService _eventService = EventService();
  final UserService _userService = UserService();

  // App models and data
  late User user;
  late Group _group;
  late Color _selectedEventColor;
  List<Event> _eventList = [];
  List<User> _users = [];
  List<User> _selectedUsers = [];
  Group? fetchedUpdatedGroup;

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationController = TextEditingController();

  // Logic states
  bool isRepetitive = false;
  bool isLoading = true;
  final double toggleWidth = 50.0;
  RecurrenceRule? _recurrenceRule;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;

  // Initialize state from group
  void initializeLogic(Group group, BuildContext context) async {
    _group = group;
    _selectedEventColor = ColorManager.eventColors.last;
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
    _eventList = _group.calendar.events;

    if (_group.userIds.isNotEmpty) {
      for (var userId in _group.userIds) {
        User user = await _userService.getUserById(userId);
        _users.add(user);
      }
    }

    isLoading = false;
    if (mounted) setState(() {});
  }

  void disposeControllers() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _locationController.dispose();
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: isStartDate
            ? TimeOfDay.fromDateTime(_selectedStartDate)
            : TimeOfDay.fromDateTime(_selectedEndDate),
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        final parsedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss')
            .parse(DateFormat('yyyy-MM-dd HH:mm:ss').format(newDateTime), true);

        if (isStartDate) {
          _selectedStartDate = parsedDateTime;
        } else {
          _selectedEndDate = parsedDateTime;
        }

        if (mounted) setState(() {});
      }
    }
  }

  Future<void> addEvent(
    BuildContext context,
    VoidCallback onSuccess,
    VoidCallback onError,
    VoidCallback onRepetitionError,
  ) async {
    final title = _titleController.text.trim();
    final location = _locationController.text.replaceAll(RegExp(r'[┤├]'), '');

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for the event.')),
      );
      return;
    }

    final newEvent = Event(
      id: Utilities.generateRandomId(10),
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
      title: title,
      groupId: _group.id,
      recurrenceRule: _recurrenceRule,
      localization: location,
      allDay: false,
      description: _descriptionController.text,
      eventColorIndex: ColorManager().getColorIndex(_selectedEventColor),
      recipients: _selectedUsers.map((u) => u.id).toList(),
      ownerID: user.id,
    );

    final exists = _eventList.any((existing) =>
        existing.startDate.year == newEvent.startDate.year &&
        existing.startDate.month == newEvent.startDate.month &&
        existing.startDate.day == newEvent.startDate.day &&
        existing.startDate.hour == newEvent.startDate.hour);

    if (exists) {
      onRepetitionError();
      return;
    }

    final created = await _eventService.createEvent(newEvent);

    if (created) {
      final addedEvent = _eventService.event;
      _eventList.add(addedEvent);
      user.events.add(addedEvent.id);

      await userManagement.updateUser(user);
      _group.calendar.events.add(addedEvent);
      await groupManagement.updateGroup(_group, userManagement);

      fetchedUpdatedGroup =
          await groupManagement.groupService.getGroupById(_group.id);

      if (fetchedUpdatedGroup == null) {
        devtools.log("Failed to fetch updated group.");
        onError();
        return;
      }

      groupManagement.currentGroup = fetchedUpdatedGroup!;
      clearFormFields();
      onSuccess();
    } else {
      onError();
    }
  }

  void clearFormFields() {
    _titleController.clear();
    _descriptionController.clear();
    _noteController.clear();
    _locationController.clear();
  }

  // Getters
  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get noteController => _noteController;
  TextEditingController get locationController => _locationController;

  Color get selectedEventColor => _selectedEventColor;
  List<Color> get colorList => ColorManager.eventColors;
  DateTime get selectedStartDate => _selectedStartDate;
  DateTime get selectedEndDate => _selectedEndDate;
  List<User> get users => _users;
  List<User> get selectedUsers => _selectedUsers;
  Group? get updatedGroup => fetchedUpdatedGroup;

  void setSelectedColor(Color color) {
    _selectedEventColor = color;
    if (mounted) setState(() {});
  }

  void toggleRepetition(bool value, RecurrenceRule? rule) {
    isRepetitive = value;
    _recurrenceRule = rule;
    if (mounted) setState(() {});
  }

  void setSelectedUsers(List<User> users) {
    _selectedUsers = users;
    if (mounted) setState(() {});
  }

  // Dialog placeholders to avoid error
  @override
  void showRepetitionDialog(BuildContext context) {
    // Implement if needed or from AddEventDialogs mixin
  }

  @override
  void showErrorDialog(BuildContext context) {
    // Implement if needed or from AddEventDialogs mixin
  }

  @override
  Widget buildRepetitionDialog(BuildContext context) {
    // Implement if needed or from AddEventDialogs mixin
    return const SizedBox.shrink();
  }

  @override
  void showGroupFetchErrorDialog(BuildContext context) {
    // Implement if needed or from AddEventDialogs mixin
  }
}
