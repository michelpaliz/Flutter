import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:flutter/material.dart';

abstract class EventFormLogic {
  /// Event color selection
  int? get selectedEventColor; // stored as int internally
  List<int> get colorList; // list of color values (ARGB integers)
  void setSelectedColor(int colorValue);

  /// Text inputs
  TextEditingController get titleController;
  TextEditingController get locationController;
  TextEditingController get descriptionController;
  TextEditingController get noteController;

  /// Date selection
  DateTime get selectedStartDate;
  DateTime get selectedEndDate;
  void selectDate(BuildContext context, bool isStart);

  /// Repetition
  bool get isRepetitive;
  double get toggleWidth;
  void toggleRepetition(bool value, RecurrenceRule? rule);

  /// User selection
  List<User> get users;
  void setSelectedUsers(List<User> selected);

  Future<void> addEvent(
    BuildContext context,
    VoidCallback onSuccess,
    VoidCallback onError,
    VoidCallback onRepetitionError,
  );
}
