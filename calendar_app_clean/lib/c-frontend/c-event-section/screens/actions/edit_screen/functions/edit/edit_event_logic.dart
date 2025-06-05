import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/b-backend/api/user/user_services.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';

abstract class EditEventLogic<T extends StatefulWidget>
    extends BaseEventLogic<T> {
  // Services
  late final EventService _eventService;
  final UserService _userService = UserService();
  late final GroupManagement _groupMgmt;
  late final UserManagement _userMgmt;
  bool isLoading = true;

  // Models
  late final Group _group;
  late Event _event;

  @override
  void initState() {
    super.initState();
    initializeBaseDefaults(); // ← must be called before using dates
  }

  Future<void> initLogic({
    required Event event,
    required GroupManagement gm,
    required UserManagement um,
  }) async {
    _eventService = EventService();
    _groupMgmt = gm;
    _userMgmt = um;
    _event = event;
    _group = gm.currentGroup!;

    // Base state setup
    setSelectedColor(ColorManager.eventColors[event.eventColorIndex].value);
    setRecurrenceRule(event.recurrenceRule);
    setStartDate(event.startDate);
    setEndDate(event.endDate);

    titleController.text = event.title;
    descriptionController.text = event.description ?? '';
    noteController.text = event.note ?? '';
    locationController.text = event.localization ?? '';

    // 🔄 Fetch users from group userIds
    final List<User> fetchedUsers = [];
    for (var id in _group.userIds) {
      try {
        final user = await _userService.getUserById(id);
        fetchedUsers.add(user);
      } catch (_) {}
    }

    // Set available users and selected recipients
    setSelectedUsers(
      fetchedUsers.where((u) => event.recipients.contains(u.id)).toList(),
    );
    users.clear();
    users.addAll(fetchedUsers);

    if (mounted) {
      isLoading = false;
      setState(() {});
    }
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
      recipients: selectedUsers.map((u) => u.id).toList(),
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

  // No-op in edit mode
  Future<void> addEvent(
    BuildContext context,
    VoidCallback onSuccess,
    VoidCallback onError,
    VoidCallback onRepetitionError,
  ) async {}

  @override
  bool get isRepetitive => recurrenceRule != null;
}
