import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/event/event_services.dart';
import 'package:calendar_app_frontend/b-backend/api/user/user_services.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
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

  Future<void> saveEditedEvent(EventDataManager read) async {
    // final eventDataManager = context.read<EventDataManager>();
    final eventDataManager = read;

    // ✅ Add this line for debugging before creating the updated event
    debugPrint(
        "Saving event with start: $selectedStartDate, end: $selectedEndDate");

    debugPrint("📅 selectedEndDate (local): $selectedEndDate");
    debugPrint("📅 selectedEndDate (UTC): ${selectedEndDate.toUtc()}");
    debugPrint(
        "📅 selectedEndDate.toIso8601String(): ${selectedEndDate.toIso8601String()}");

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

    await eventDataManager.updateEvent(updated); // ✅ Syncs with state + backend

    // // 🔁 Pull latest version from backend (if someone else also edited)
    // await eventDataManager.manualRefresh();

    // ✅ Notify calendar to refresh visuals

    if (eventDataManager.onExternalEventUpdate != null) {
      debugPrint(
        "🔍 EventDataManager hash: ${identityHashCode(eventDataManager)}",
      );

      debugPrint("🔁 Triggering calendar refresh from EditEventLogic...");
      eventDataManager.onExternalEventUpdate!.call();
    } else {
      //  This ensures that at least the data updates, even if the UI doesn't automatically reflect it.
      debugPrint(
        "⚠️ onExternalEventUpdate is null — triggering manual refresh.",
      );
      await eventDataManager.manualRefresh();
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
