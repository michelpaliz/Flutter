import 'package:flutter/material.dart';
import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';

mixin EditEventLogic<T extends StatefulWidget> on State<T> {
  // ── injected services ─────────────────────────────────────────────────────
  late final EventService      _eventService;
  late final GroupManagement   _groupMgmt;
  late final UserManagement    _userMgmt;

  // ── models & UI state ──────────────────────────────────────────────────────
  late final Group   _group;
  late       Event   _event;
  late       Color   _selectedColor;
  RecurrenceRule?    _recurrenceRule;
  late       DateTime _selectedStartDate;
  late       DateTime _selectedEndDate;
  final      double   _toggleWidth = 50.0;                // ← you forgot this

  // ── text controllers ──────────────────────────────────────────────────────
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _noteController;
  late final TextEditingController _locationController;

  /// Call once to wire everything up.
  void initLogic({
    required Event              event,
    required GroupManagement    gm,
    required UserManagement     um,
  }) {
    _eventService      = EventService();
    _groupMgmt         = gm;
    _userMgmt          = um;
    _event             = event;
    _group             = gm.currentGroup!;

    // init UI state
    _selectedColor     = ColorManager.eventColors[event.eventColorIndex];
    _recurrenceRule    = event.recurrenceRule;
    _selectedStartDate = event.startDate;
    _selectedEndDate   = event.endDate;

    // init controllers
    _titleController       = TextEditingController(text: event.title);
    _descriptionController = TextEditingController(text: event.description ?? '');
    _noteController        = TextEditingController(text: event.note        ?? '');
    _locationController    = TextEditingController(text: event.localization ?? '');
  }

  /// Clean up.
  void disposeLogic() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _locationController.dispose();
  }

  /// Combines date+time pickers.
  Future<DateTime?> showDateTimePicker(BuildContext ctx, DateTime initial) async {
    final date = await showDatePicker(
      context:    ctx,
      initialDate: initial,
      firstDate:   DateTime(2000),
      lastDate:    DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context:     ctx,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;

    return DateTime(
      date.year, date.month, date.day, time.hour, time.minute,
    );
  }

  /// Build the updated event and save it.
  Future<void> saveEditedEvent() async {
    final updated = Event(
      id:              _event.id,
      startDate:       _selectedStartDate,
      endDate:         _selectedEndDate,
      title:           _titleController.text,
      groupId:         _event.groupId,
      description:     _descriptionController.text,
      note:            _noteController.text,
      localization:    _locationController.text.replaceAll(RegExp(r'[┤├]'), ''),
      recurrenceRule:  _recurrenceRule,
      eventColorIndex: ColorManager().getColorIndex(_selectedColor),
      recipients:      _event.recipients,
      updateHistory:   _event.updateHistory,
      ownerId:         _event.ownerId,
    );

    await _eventService.updateEvent(updated.id, updated);
    final evs = _group.calendar.events;
    final idx = evs.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      evs[idx] = updated;
      _groupMgmt.currentGroup = _group;
    }
    Navigator.of(context).pop(true);
  }

  // ── public getters & setters ───────────────────────────────────────────────
  Color                 get selectedColor     => _selectedColor;
  double                get toggleWidth       => _toggleWidth;
  TextEditingController get titleController   => _titleController;
  TextEditingController get descriptionController => _descriptionController;
  TextEditingController get noteController    => _noteController;
  TextEditingController get locationController=> _locationController;
  DateTime              get selectedStartDate => _selectedStartDate;
  DateTime              get selectedEndDate   => _selectedEndDate;
  RecurrenceRule?       get recurrenceRule    => _recurrenceRule;

  void setSelectedColor(Color c)       => setState(() => _selectedColor = c);
  void setRecurrenceRule(bool r, RecurrenceRule? rule) {
    setState(() => _recurrenceRule = rule);
  }
  void setStartDate(DateTime dt)       => setState(() {
    _selectedStartDate = dt;
    if (_selectedEndDate.isBefore(dt)) {
      _selectedEndDate = dt.add(const Duration(hours: 1));
    }
  });
  void setEndDate(DateTime dt)         => setState(() => _selectedEndDate = dt);
}
