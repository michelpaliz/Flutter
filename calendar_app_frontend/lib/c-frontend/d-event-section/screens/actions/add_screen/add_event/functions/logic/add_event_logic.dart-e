import 'dart:developer' as devtools show log;

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/b-backend/api/client/client_api.dart';
import 'package:calendar_app_frontend/b-backend/api/service/service_api.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/add_screen/add_event/functions/helper/add_event_helpers.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/utils/color_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../../../a-models/user_model/user.dart';
import '../../../../../../../../../b-backend/api/user/user_services.dart';
import '../../../../../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../../../../../d-stateManagement/user/user_management.dart';
import '../../../../../../../../../f-themes/utilities/utilities.dart';

abstract class AddEventLogic<T extends StatefulWidget>
    extends BaseEventLogic<T> {
  // Services
  late EventDataManager _eventDataManager;
  late UserManagement userManagement;
  late GroupManagement groupManagement;
  late NotificationManagement notificationManagement;
  final UserService _userService = UserService();
  final _clientsApi = ClientsApi();
  final _servicesApi = ServiceApi();

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

    // sane defaults
    setSelectedColor(ColorManager.eventColors.last.value);
    final now = DateTime.now();
    setStartDate(now);
    setEndDate(now.add(const Duration(hours: 1)));

    _eventDataManager = Provider.of<EventDataManager>(context, listen: false);

    // preload users for invite UI
    if (_group.userIds.isNotEmpty) {
      for (final userId in _group.userIds) {
        final fetchedUser = await _userService.getUserById(userId);
        users.add(fetchedUser);
      }
    }

    // ✅ Load clients/services and push to logic without using displayName
    try {
      final clients = await _clientsApi.list(groupId: _group.id);
      setAvailableClients(
        clients
            .map((c) => ClientLite(
                  id: c.id,
                  name: c.name, // <-- no displayName here
                ))
            .toList(),
      );
    } catch (e) {
      devtools.log('⚠️ clients fetch failed: $e');
      setAvailableClients(const []);
    }

    try {
      final services = await _servicesApi.list(groupId: _group.id);
      setAvailableServices(
        services
            .map((s) => ServiceLite(
                  id: s.id,
                  name: s.name,
                ))
            .toList(),
      );
    } catch (e) {
      devtools.log('⚠️ services fetch failed: $e');
      setAvailableServices(const []);
    }

    if (mounted) setState(() {});
  }

  void disposeControllers() {
    disposeBaseControllers(); // 🧼 from BaseEventLogic
  }

  // @override
  // Future<bool> addEvent(BuildContext context) async {
  //   devtools.log("🚀 [addEvent] called");

  //   if (!validateTitle(context, titleController)) return false;

  //   if (!validateRecurrence(
  //     recurrenceRule: recurrenceRule,
  //     selectedStartDate: selectedStartDate,
  //   )) return false;

  //   // 🔓 Allow zero invitees
  //   if (selectedUsers.isEmpty) {
  //     devtools.log("ℹ️ [addEvent] No invitees selected (allowed)");
  //   }

  //   //Fetch the current calendar id from the server
  //   final calId = _group.calendarId;
  //   if (calId == null) {
  //     // optional: refetch once as a fallback
  //     final refreshed =
  //         await groupManagement.groupService.getGroupById(_group.id);
  //     final fallbackCalId =
  //         refreshed.defaultCalendarId ?? refreshed.defaultCalendar?.id;
  //     if (fallbackCalId == null) {
  //       // show error to the user and bail out
  //       // ...
  //       return false;
  //     }
  //     // use fallbackCalId
  //     // ...
  //   }

  //   final newEvent = buildNewEvent(
  //     id: Utilities.generateRandomId(10),
  //     startDate: selectedStartDate,
  //     endDate: selectedEndDate,
  //     title: titleController.text.trim(),
  //     groupId: _group.id,
  //     calendarId: calId!,
  //     recurrenceRule: recurrenceRule,
  //     location: locationController.text.replaceAll(RegExp(r'[┤├]'), ''),
  //     description: descriptionController.text,
  //     eventColorIndex: ColorManager().getColorIndex(Color(selectedEventColor!)),
  //     recipients: selectedUsers.map((u) => u.id).toList(), // ✅ [] when none
  //     ownerId: user.id,
  //   );

  //   try {
  //     final createdEvent =
  //         await _eventDataManager.createEvent(context, newEvent);

  //     await hydrateRecurrenceRuleIfNeeded(
  //       groupManagement: groupManagement,
  //       rawRuleId: createdEvent.rawRuleId,
  //     );

  //     await _postCreationActions(createdEvent);

  //     devtools.log("🎉 [addEvent] Success");
  //     return true;
  //   } catch (e, stack) {
  //     devtools.log('💥 [addEvent] Exception: $e\n$stack');
  //     return false;
  //   } finally {
  //     devtools.log("🏁 [addEvent] Finished execution");
  //   }
  // }

  Future<void> _postCreationActions(Event createdEvent) async {
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

    await _eventDataManager.manualRefresh(context);
    devtools.log("♻️ Manual refresh complete");

    clearFormFields();
    devtools.log("🧹 Form cleared");
  }

  // Future<String?> _resolveValidCalendarId() async {
  //   // 1) try local fields in the widget group
  //   String? id = _group.defaultCalendarId ??
  //       _group.defaultCalendar?.id ??
  //       _group.calendarId;

  //   // 2) if still null, refresh group once
  //   if (id == null || id.isEmpty) {
  //     final refreshed =
  //         await groupManagement.groupService.getGroupById(_group.id);
  //     id = refreshed.defaultCalendarId ??
  //         refreshed.defaultCalendar?.id ??
  //         refreshed.calendarId;
  //   }

  //   // 3) validate ObjectId format (what Mongo expects)
  //   final isValidObjectId =
  //       id != null && RegExp(r'^[a-f0-9]{24}$').hasMatch(id);
  //   return isValidObjectId ? id : null;
  // }

  @override
  Future<bool> addEvent(BuildContext context) async {
    devtools.log("🚀 [addEvent] called");

    final isWorkVisit = eventType == 'work_visit';

    // ✅ Only require title for SIMPLE events
    if (!isWorkVisit) {
      if (!validateTitle(context, titleController)) return false;
    }

    // Recurrence validation (unchanged)
    if (!validateRecurrence(
      recurrenceRule: recurrenceRule,
      selectedStartDate: selectedStartDate,
    )) return false;

    // Optional: enforce client/service for work-visit
    if (isWorkVisit) {
      if ((clientId == null || clientId!.isEmpty) ||
          (primaryServiceId == null || primaryServiceId!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select client & service')),
        );
        return false;
      }
    }

    // 🔧 Auto-compose a title for work-visit if user left it empty
    String title = titleController.text.trim();
    if (isWorkVisit && title.isEmpty) {
      final clientName = clients
          .firstWhere((c) => c.id == clientId,
              orElse: () => const ClientLite(id: '', name: null))
          .name;
      final serviceName = services
          .firstWhere((s) => s.id == primaryServiceId,
              orElse: () => const ServiceLite(id: '', name: null))
          .name;

      if (clientName != null && serviceName != null) {
        title = '$serviceName — $clientName';
      } else if (clientName != null) {
        title = 'Visit — $clientName';
      } else if (serviceName != null) {
        title = '$serviceName visit';
      } else {
        title = 'Work visit';
      }
    }

    // Ensure calendarId (with fallback)
    String? calId = _group.calendarId;
    if (calId == null) {
      final refreshed =
          await groupManagement.groupService.getGroupById(_group.id);
      calId = refreshed.defaultCalendarId ?? refreshed.defaultCalendar?.id;
      if (calId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No calendar configured for this group')),
        );
        return false;
      }
    }

// hard-stop if the user didn’t pick both (your isFormValid already enforces this,
// but keep this guard here too to be explicit)
    if (isWorkVisit) {
      if ((clientId == null || clientId!.isEmpty) ||
          (primaryServiceId == null || primaryServiceId!.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select client & service')),
        );
        return false;
      }
    }

// Build visitServices ONLY from user’s selected primaryServiceId
    final vs = isWorkVisit
        ? [
            VisitService(serviceId: primaryServiceId!), // user-picked
          ]
        : const <VisitService>[];

    // Build event with NEW fields
    final newEvent = buildNewEvent(
        id: Utilities.generateRandomId(10),
        startDate: selectedStartDate,
        endDate: selectedEndDate,
        title: title,
        groupId: _group.id,
        calendarId: calId,
        recurrenceRule: recurrenceRule,
        location: locationController.text.replaceAll(RegExp(r'[┤├]'), ''),
        description: descriptionController.text,
        eventColorIndex:
            ColorManager().getColorIndex(Color(selectedEventColor!)),
        recipients: selectedUsers.map((u) => u.id).toList(),
        ownerId: user.id,

        // NEW: send the right fields per type
        type: isWorkVisit ? 'work_visit' : 'simple',
        clientId: isWorkVisit ? clientId : null,
        primaryServiceId: isWorkVisit ? primaryServiceId : null,
        categoryId: !isWorkVisit ? categoryId : null,
        subcategoryId: !isWorkVisit ? subcategoryId : null,
        visitServices: vs // add when you implement the editor
        );

    try {
      final created = await _eventDataManager.createEvent(context, newEvent);

      await hydrateRecurrenceRuleIfNeeded(
        groupManagement: groupManagement,
        rawRuleId: created.rawRuleId,
      );

      await _postCreationActions(created);
      devtools.log("🎉 [addEvent] Success");
      return true;
    } catch (e, stack) {
      devtools.log('💥 [addEvent] Exception: $e\n$stack');
      return false;
    } finally {
      devtools.log("🏁 [addEvent] Finished execution");
    }
  }

  void clearFormFields() {
    titleController.clear();
    descriptionController.clear();
    noteController.clear();
    locationController.clear();
  }

  Group? get updatedGroup => fetchedUpdatedGroup;
}
