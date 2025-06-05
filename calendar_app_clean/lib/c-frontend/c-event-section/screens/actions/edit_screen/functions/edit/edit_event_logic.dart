import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';

abstract class EditEventLogic<T extends StatefulWidget>
    extends BaseEventLogic<T> {
  // ── injected services ─────────────────────────────────────────────────────
  late final EventService _eventService;
  late final GroupManagement _groupMgmt;
  late final UserManagement _userMgmt;

  // ── models ────────────────────────────────────────────────────────────────
  late final Group _group;
  late Event _event;

  @override
  void initState() {
    super.initState();
    initializeBaseDefaults(); // ← must be called before using dates
  }

  /// Call once to wire everything up.
  void initLogic({
    required Event event,
    required GroupManagement gm,
    required UserManagement um,
  }) {
    _eventService = EventService();
    _groupMgmt = gm;
    _userMgmt = um;
    _event = event;
    _group = gm.currentGroup!;

    // ✅ Use public setters from BaseEventLogic
    setSelectedColor(ColorManager.eventColors[event.eventColorIndex].value);
    setRecurrenceRule(event.recurrenceRule);
    setStartDate(event.startDate);
    setEndDate(event.endDate);

    // ✅ Use public controller fields
    titleController.text = event.title;
    descriptionController.text = event.description ?? '';
    noteController.text = event.note ?? '';
    locationController.text = event.localization ?? '';
  }

  void disposeLogic() {
    disposeBaseControllers(); // 🧼 from BaseEventLogic
  }

  Future<void> saveEditedEvent() async {
    final updated = Event(
      id: _event.id,
      startDate: selectedStartDate,
      endDate: selectedEndDate,
      title: titleController.text,
      groupId: _event.groupId,
      description: descriptionController.text,
      note: noteController.text,
      localization: locationController.text.replaceAll(RegExp(r'[┤├]'), ''),
      recurrenceRule: recurrenceRule,
      eventColorIndex: ColorManager().getColorIndex(Color(selectedEventColor!)),
      recipients: _event.recipients,
      updateHistory: _event.updateHistory,
      ownerId: _event.ownerId,
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

  // Unused methods from EventFormLogic in Edit mode
  Future<void> addEvent(
    BuildContext context,
    VoidCallback onSuccess,
    VoidCallback onError,
    VoidCallback onRepetitionError,
  ) async {
    // No-op
  }

  @override
  void setSelectedUsers(List<User> selected) {
    // No-op
  }

  @override
  List<User> get users => [];

  @override
  bool get isRepetitive => recurrenceRule != null;
}
