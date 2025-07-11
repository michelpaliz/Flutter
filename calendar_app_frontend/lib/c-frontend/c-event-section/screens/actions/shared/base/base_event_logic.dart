import 'package:calendar_app_frontend/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';

abstract class BaseEventLogic<T extends StatefulWidget> extends State<T> {
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();
  final _locationController = TextEditingController();

  // UI state
  late Color _selectedEventColor;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  LegacyRecurrenceRule? _recurrenceRule;
  final double _toggleWidth = 50.0;

  // User selection (used in Add flow, no-op in Edit)
  @protected
  List<User> _users = [];

  @protected
  List<User> _selectedUsers = [];

  // ───── Initialization ─────
  void initializeBaseDefaults() {
    _selectedEventColor = ColorManager.eventColors.last;
    _selectedStartDate = DateTime.now();
    _selectedEndDate = _selectedStartDate.add(const Duration(hours: 1));
    _recurrenceRule = null;
    _users = [];
    _selectedUsers = [];
  }

  // ───── Shared controller access ─────
  TextEditingController get titleController => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get noteController => _noteController;
  TextEditingController get locationController => _locationController;

  // ───── Shared state access ─────
  int? get selectedEventColor => _selectedEventColor.value;
  List<int> get colorList =>
      ColorManager.eventColors.map((c) => c.value).toList();

  DateTime get selectedStartDate => _selectedStartDate;
  DateTime get selectedEndDate => _selectedEndDate;
  LegacyRecurrenceRule? get recurrenceRule => _recurrenceRule;

  double get toggleWidth => _toggleWidth;
  bool get isRepetitive => _recurrenceRule != null;

  List<User> get users => _users;
  List<User> get selectedUsers => _selectedUsers;

  // ───── Shared mutators ─────
  void setSelectedColor(int colorValue) {
    _selectedEventColor = Color(colorValue);
    if (mounted) setState(() {});
  }

  void toggleRepetition(bool value, LegacyRecurrenceRule? rule) {
    _recurrenceRule = value ? rule : null;
    if (mounted) setState(() {});
  }

  void setRecurrenceRule(LegacyRecurrenceRule? rule) {
    _recurrenceRule = rule;
    if (mounted) setState(() {});
  }

  void setSelectedUsers(List<User> users) {
    _selectedUsers = users;
    if (mounted) setState(() {});
  }

  void setStartDate(DateTime dt) => setState(() {
        _selectedStartDate = dt;
        if (_selectedEndDate.isBefore(dt)) {
          _selectedEndDate = dt.add(const Duration(hours: 1));
        }
      });

  void setEndDate(DateTime dt) => setState(() {
        _selectedEndDate = dt;
      });

  Future<void> selectDate(BuildContext context, bool isStart) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _selectedStartDate : _selectedEndDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart ? _selectedStartDate : _selectedEndDate,
        ),
      );

      if (pickedTime != null) {
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        isStart ? setStartDate(combined) : setEndDate(combined);
      }
    }
  }

  void disposeBaseControllers() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _locationController.dispose();
  }

  /// Intended to be implemented by subclasses like AddEventLogic
  Future<bool> addEvent(BuildContext context);
}
