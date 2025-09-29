import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/api/event/event_services.dart';
import 'package:hexora/b-backend/api/user/user_services.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:hexora/c-frontend/d-event-section/utils/color_manager.dart';
import 'package:hexora/d-stateManagement/event/event_data_manager.dart';
import 'package:hexora/d-stateManagement/group/group_management.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
import 'package:hexora/l10n/app_localizations.dart';
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
    setReminderMinutes(event.reminderTime ?? 10);
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
        fetchedUsers.add(user!);
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

  Future<void> saveEditedEvent(EventDataManager read) async {
    final loc = AppLocalizations.of(context)!;
    final eventDataManager = read;

    // 🔒 Validate required title
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.requiredTextFields),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 🔒 Validate at least one participant
    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.pleaseSelectAtLeastOneUser),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 🔒 Validate start and end date
    if (selectedEndDate.isBefore(selectedStartDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.endDateMustBeAfterStartDate),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
      reminderTime: reminderMinutes,
    );

    await eventDataManager.updateEvent(context, updated);

    if (eventDataManager.onExternalEventUpdate != null) {
      debugPrint("🔁 Triggering calendar refresh from EditEventLogic...");
      eventDataManager.onExternalEventUpdate!.call();
    } else {
      debugPrint(
          "⚠️ onExternalEventUpdate is null — triggering manual refresh.");
      await eventDataManager.manualRefresh(context);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  // No-op in edit mode
  @override
  Future<bool> addEvent(BuildContext context) async {
    return false; // or throw UnimplementedError() if you want to enforce that
  }

  @override
  bool get isRepetitive => recurrenceRule != null;
}
