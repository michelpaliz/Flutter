import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/b-backend/group_mng_flow/event/domain/event_domain.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/business_logic/client/client_api.dart';
import 'package:hexora/b-backend/business_logic/service/service_api_client.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/add_event/functions/helper/add_event_helpers.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/shared/base/base_event_logic.dart';
import 'package:hexora/c-frontend/d-event-section/utils/color_manager.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../a-models/group_model/group/group.dart';
import '../../../../../../../../../a-models/user_model/user.dart';
import '../../../../../../../../f-themes/app_utilities/app_utils.dart';
import '../../../../../../../../b-backend/group_mng_flow/group/domain/group_domain.dart';
import '../../../../../../../../b-backend/auth_user/user/api/user_api_client.dart';
import '../../../../../../../../b-backend/notification/domain/notification_domain.dart';

abstract class AddEventLogic<T extends StatefulWidget>
    extends BaseEventLogic<T> {
  // Services
  late EventDomain _eventDomain;
  late UserDomain userDomain;
  late GroupDomain groupDomain;
  late NotificationDomain notificationDomain;
  final UserApiClient _userService = UserApiClient();
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
    required GroupDomain groupDomain,
    required UserDomain userDomain,
    required NotificationDomain notifMgmt,
  }) {
    groupDomain = groupDomain;
    userDomain = userDomain;
    notificationDomain = notifMgmt;
    user = userDomain.user!;
  }

// ───────── initializeLogic ─────────
  Future<void> initializeLogic(Group group, BuildContext context) async {
    _group = group;

    // sane defaults
    setSelectedColor(ColorManager.eventColors.last.value);
    final now = DateTime.now();
    setStartDate(now);
    setEndDate(now.add(const Duration(hours: 1)));

    _eventDomain = Provider.of<EventDomain>(context, listen: false);

    // ✅ Preload users via userDomain (no direct service calls)
    try {
      final groupUsers = await userDomain.getUsersForGroup(_group);
      users.addAll(
          groupUsers.where((u) => users.indexWhere((x) => x.id == u.id) == -1));
    } catch (e) {
      devtools.log('⚠️ preload users failed: $e');
    }

    // ✅ Load clients/services stays as-is if those APIs already encapsulate token
    try {
      final clients = await _clientsApi.list(groupId: _group.id);
      setAvailableClients(
        clients.map((c) => ClientLite(id: c.id, name: c.name)).toList(),
      );
    } catch (e) {
      devtools.log('⚠️ clients fetch failed: $e');
      setAvailableClients(const []);
    }

    try {
      final services = await _servicesApi.list(groupId: _group.id);
      setAvailableServices(
        services.map((s) => ServiceLite(id: s.id, name: s.name)).toList(),
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

// ───────── _postCreationActions ─────────
  Future<void> _postCreationActions(Event createdEvent) async {
    await userDomain.updateUser(user);
    devtools.log("👤 [addEvent] User updated");

    // ✅ Fetch updated group via repository (no direct service)
    fetchedUpdatedGroup =
        await groupDomain.groupRepository.getGroupById(_group.id);
    if (fetchedUpdatedGroup == null) {
      devtools.log("❌ [addEvent] Failed to fetch updated group");
      return;
    }

    groupDomain.currentGroup = fetchedUpdatedGroup!;
    devtools.log(
        "🧹 [addEvent] GROUP FETCHED: ${fetchedUpdatedGroup!.name} (${fetchedUpdatedGroup!.id})");

    if (_eventDomain.onExternalEventUpdate != null) {
      devtools.log("🔁 Triggering external calendar refresh...");
      _eventDomain.onExternalEventUpdate!.call();
    } else {
      devtools.log("⚠️ No external calendar update hook found");
    }

    await _eventDomain.manualRefresh(context);
    devtools.log("♻️ Manual refresh complete");

    clearFormFields();
    devtools.log("🧹 Form cleared");
  }

// AddEventLogic.addEvent(...)
  @override
  Future<bool> addEvent(BuildContext context) async {
    devtools.log("🚀 [addEvent] called");

    // ---- infer work visit from actual selections (robust) ----
    final hasClient = (clientId != null && clientId!.isNotEmpty);
    final hasPrimaryService =
        (primaryServiceId != null && primaryServiceId!.isNotEmpty);
    final isWorkVisit = hasClient || hasPrimaryService;

    // ---- validate recurrence (unchanged) ----
    if (!validateRecurrence(
      recurrenceRule: recurrenceRule,
      selectedStartDate: selectedStartDate,
    )) return false;

    // ---- SIMPLE requires title; WORK_VISIT requires client+service ----
    if (!isWorkVisit) {
      if (!validateTitle(context, titleController)) return false;
    } else {
      if (!hasClient || !hasPrimaryService) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select client & service')),
        );
        return false;
      }
    }

    // ───────── ensure calendarId (with refresh fallback) ─────────
    String? calId = _group.calendarId;
    if (calId == null) {
      // ✅ Use repository to re-fetch (handles token)
      final refreshed =
          await groupDomain.groupRepository.getGroupById(_group.id);

      calId = refreshed.defaultCalendarId ?? refreshed.defaultCalendar?.id;
      if (calId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No calendar configured for this group')),
        );
        return false;
      }
    }

    // ---- compose title if empty for work visits ----
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

    // ---- build visitServices (include primary selected service) ----
    final List<VisitService> vs = isWorkVisit
        ? [VisitService(serviceId: primaryServiceId!)]
        : const <VisitService>[];

    // ---- build the event payload (derive type from selections) ----
    final newEvent = buildNewEvent(
      id: AppUtils.generateRandomId(10),
      startDate: selectedStartDate,
      endDate: selectedEndDate,
      title: title,
      groupId: _group.id,
      calendarId: calId,
      recurrenceRule: recurrenceRule,
      location: locationController.text.replaceAll(RegExp(r'[┤├]'), ''),
      description: descriptionController.text,
      eventColorIndex: ColorManager().getColorIndex(Color(selectedEventColor!)),
      recipients: selectedUsers.map((u) => u.id).toList(),
      ownerId: user.id,

      // 🔑 derive type from actual selections
      type: isWorkVisit ? 'work_visit' : 'simple',

      // 🔑 include work fields if present
      clientId: isWorkVisit ? clientId : null,
      primaryServiceId: isWorkVisit ? primaryServiceId : null,
      visitServices: vs,

      // keep legacy only when simple
      categoryId: isWorkVisit ? null : categoryId,
      subcategoryId: isWorkVisit ? null : subcategoryId,
    );

    try {
      // optional: log the exact backend body
      devtools.log('📤 [addEvent] toBackendJson: ${newEvent.toBackendJson()}');

      final created = await _eventDomain.createEvent(context, newEvent);

      await hydrateRecurrenceRuleIfNeeded(
        groupDomain: groupDomain,
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
