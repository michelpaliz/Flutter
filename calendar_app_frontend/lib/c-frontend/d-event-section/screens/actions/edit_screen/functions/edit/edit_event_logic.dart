import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/event/api/event_api_client.dart';
import 'package:hexora/b-backend/core/event/domain/event_domain.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/user/repository/user_repository.dart'; // ⬅️ use repo, not service
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:hexora/c-frontend/d-event-section/utils/color_manager.dart';
import 'package:hexora/l10n/app_localizations.dart';

abstract class EditEventLogic<T extends StatefulWidget>
    extends BaseEventLogic<T> {
  // Services
  late final EventApiClient _eventService;
  late final GroupDomain _groupMgmt;
  late final UserDomain _userMgmt;
  late final UserRepository _userRepo; // ⬅️ repository handles token
  bool isLoading = true;

  // Models
  late final Group _group;
  late Event _event;

  @override
  void initState() {
    super.initState();
    initializeBaseDefaults();
  }

  Future<void> initLogic({
    required Event event,
    required GroupDomain gm,
    required UserDomain um,
  }) async {
    _eventService = EventApiClient();
    _groupMgmt = gm;
    _userMgmt = um;
    _userRepo = _userMgmt.userRepository; // ⬅️ grab repo from management
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

    // 🔄 Fetch users from group userIds (via repo → token handled)
    final List<User> fetchedUsers = [];
    for (final id in _group.userIds) {
      try {
        final user = await _userRepo.getUserById(id);
        fetchedUsers.add(user);
      } catch (_) {
        // ignore failures for individual users
      }
    }

    // Set available users and selected recipients
    setSelectedUsers(
      fetchedUsers.where((u) => event.recipients.contains(u.id)).toList(),
    );
    users
      ..clear()
      ..addAll(fetchedUsers);

    if (mounted) {
      isLoading = false;
      setState(() {});
    }
  }

  void disposeLogic() {
    disposeBaseControllers();
  }

  Future<void> saveEditedEvent(EventDomain read) async {
    final loc = AppLocalizations.of(context)!;
    final eventDataManager = read;

    // Required title
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(loc.requiredTextFields),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    // At least one participant
    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(loc.pleaseSelectAtLeastOneUser),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    // Start before end
    if (selectedEndDate.isBefore(selectedStartDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(loc.endDateMustBeAfterStartDate),
            backgroundColor: Colors.redAccent),
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

  @override
  Future<bool> addEvent(BuildContext context) async => false;

  @override
  bool get isRepetitive => recurrenceRule != null;
}
