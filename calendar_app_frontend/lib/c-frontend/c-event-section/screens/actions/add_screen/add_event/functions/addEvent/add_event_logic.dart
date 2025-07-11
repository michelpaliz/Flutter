import 'dart:developer' as devtools show log;

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/add_event/functions/helper/add_event_helpers.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../../a-models/user_model/user.dart';
import '../../../../../../../../b-backend/api/user/user_services.dart';
import '../../../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../../../d-stateManagement/user/user_management.dart';
import '../../../../../../../../f-themes/utilities/utilities.dart';
import '../../../../../../utils/color_manager.dart';

abstract class AddEventLogic<T extends StatefulWidget>
    extends BaseEventLogic<T> {
  // Services
  late EventDataManager _eventDataManager;
  late UserManagement userManagement;
  late GroupManagement groupManagement;
  late NotificationManagement notificationManagement;
  final UserService _userService = UserService();

  // Models
  late User user;
  late Group _group;
  Group? fetchedUpdatedGroup;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeBaseDefaults(); // ← must be called before using dates
  }

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

  Future<void> initializeLogic(Group group, BuildContext context) async {
    _group = group;

    // Use BaseEventLogic setters
    setSelectedColor(ColorManager.eventColors.last.value);
    setStartDate(DateTime.now());
    setEndDate(DateTime.now());

    _eventDataManager = Provider.of<EventDataManager>(context, listen: false);

    if (_group.userIds.isNotEmpty) {
      for (var userId in _group.userIds) {
        final fetchedUser = await _userService.getUserById(userId);
        users.add(fetchedUser); // Access from BaseEventLogic
      }
    }

    if (mounted) setState(() {});
  }

  void disposeControllers() {
    disposeBaseControllers(); // 🧼 from BaseEventLogic
  }

  Future<bool> addEvent(BuildContext context) async {
    devtools.log("🚀 [addEvent] called");

    if (!validateTitle(context, titleController)) return false;

    if (!validateRecurrence(
      recurrenceRule: recurrenceRule,
      selectedStartDate: selectedStartDate,
    )) return false;

    final newEvent = buildNewEvent(
      id: Utilities.generateRandomId(10),
      startDate: selectedStartDate,
      endDate: selectedEndDate,
      title: titleController.text.trim(),
      groupId: _group.id,
      calendarId: _group.calendar.id,
      recurrenceRule: recurrenceRule,
      location: locationController.text.replaceAll(RegExp(r'[┤├]'), ''),
      description: descriptionController.text,
      eventColorIndex: ColorManager().getColorIndex(Color(selectedEventColor!)),
      recipients: selectedUsers.map((u) => u.id).toList(),
      ownerId: user.id,
    );

    try {
      final createdEvent = await _eventDataManager.createEvent(newEvent);

      await hydrateRecurrenceRuleIfNeeded(
        groupManagement: groupManagement,
        rawRuleId: createdEvent.rawRuleId,
      );

      await _postCreationActions(createdEvent);

      devtools.log("🎉 [addEvent] Success");
      return true;
    } catch (e, stack) {
      devtools.log('💥 [addEvent] Exception: $e\n$stack');
      return false;
    } finally {
      devtools.log("🏁 [addEvent] Finished execution");
    }
  }

  Future<void> _postCreationActions(Event createdEvent) async {
    user.events.add(createdEvent.id);
    await userManagement.updateUser(user);
    devtools.log("👤 [addEvent] User updated");

    fetchedUpdatedGroup =
        await groupManagement.groupService.getGroupById(_group.id);
    if (fetchedUpdatedGroup == null) {
      devtools.log("❌ [addEvent] Failed to fetch updated group");
      return;
    }

    groupManagement.currentGroup = fetchedUpdatedGroup!;
    devtools.log(
        "🧹 [addEvent] GROUP FETCHED: ${fetchedUpdatedGroup!.name} (${fetchedUpdatedGroup!.id})");

    if (_eventDataManager.onExternalEventUpdate != null) {
      devtools.log("🔁 Triggering external calendar refresh...");
      _eventDataManager.onExternalEventUpdate!.call();
    } else {
      devtools.log("⚠️ No external calendar update hook found");
    }

    await _eventDataManager.manualRefresh();
    devtools.log("♻️ Manual refresh complete");

    clearFormFields();
    devtools.log("🧹 Form cleared");
  }

  void clearFormFields() {
    titleController.clear();
    descriptionController.clear();
    noteController.clear();
    locationController.clear();
  }

  Group? get updatedGroup => fetchedUpdatedGroup;
}
