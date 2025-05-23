import 'dart:developer' as devtools show log;

import 'package:first_project/d-stateManagement/event/event_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../../a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import '../../../../../../a-models/group_model/event_appointment/event/event.dart';
import '../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../a-models/user_model/user.dart';
import '../../../../../../b-backend/api/user/user_services.dart';
import '../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../d-stateManagement/user/user_management.dart';
import '../../../../../../f-themes/utilities/utilities.dart';
import '../../../../utils/color_manager.dart';

mixin AddEventLogic<T extends StatefulWidget> on State<T> {
  // Add this dependency
  late EventDataManager _eventDataManager;

  // Services
  late UserManagement userManagement;
  late GroupManagement groupManagement;
  late NotificationManagement notificationManagement;
  final UserService _userService = UserService();

  // Models
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

  // State
  bool isRepetitive = false;
  bool isLoading = true;
  final double toggleWidth = 50.0;
  RecurrenceRule? _recurrenceRule;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;

  void injectDependencies({
    required GroupManagement groupMgmt,
    required UserManagement userMgmt,
    required NotificationManagement notifMgmt,
  }) {
    groupManagement = groupMgmt;
    userManagement = userMgmt;
    notificationManagement = notifMgmt;
    user = userManagement.user!;
  }

  // Logic
  Future<void> initializeLogic(Group group, BuildContext context) async {
    _group = group;
    _selectedEventColor = ColorManager.eventColors.last;
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
    _eventList = _group.calendar.events;

    // try to grab it—Provider.of will throw if it's missing
    late final EventDataManager edm;
    try {
      edm = Provider.of<EventDataManager>(context, listen: false);
    } catch (e) {
      assert(
          false,
          'No EventDataManager found! '
          'Make sure AddEvent is wrapped in a Provider<EventDataManager> above it.\n'
          'Original error: $e');
      rethrow; // in production this will propagate the original exception
    }
    _eventDataManager = edm;

    // Initialize EventDataManager with proper parameters
// ✅ Use shared instance from Provider
    _eventDataManager = Provider.of<EventDataManager>(context, listen: false);

    if (_group.userIds.isNotEmpty) {
      for (var userId in _group.userIds) {
        final fetchedUser = await _userService.getUserById(userId);
        _users.add(fetchedUser);
      }
    }
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
      ownerId: user.id,
      isDone: false,
      completedAt: null,
    );

    // Check for duplicates through EventDataManager
    final exists = _eventDataManager.events.any((existing) =>
        existing.startDate.year == newEvent.startDate.year &&
        existing.startDate.month == newEvent.startDate.month &&
        existing.startDate.day == newEvent.startDate.day &&
        existing.startDate.hour == newEvent.startDate.hour);

    if (exists) {
      onRepetitionError();
      return;
    }

    try {
      // Use EventDataManager to create the event
      final createdEvent = await _eventDataManager.createEvent(newEvent);

      // Update user events
      user.events.add(createdEvent.id);
      await userManagement.updateUser(user);

      // No need to manually update _group.calendar.events - EventDataManager handles it

      // Fetch updated group through groupManagement
      fetchedUpdatedGroup =
          await groupManagement.groupService.getGroupById(_group.id);
      if (fetchedUpdatedGroup == null) {
        devtools.log("Failed to fetch updated group.");
        onError();
        return;
      }

      groupManagement.currentGroup = fetchedUpdatedGroup!;

      // ✅ Sync the events with EventDataManager
      _eventDataManager.updateEvents(fetchedUpdatedGroup!.calendar.events);

      clearFormFields();
      onSuccess();
    } catch (e) {
      devtools.log('Error creating event: $e');
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
}
