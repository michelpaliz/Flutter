// lib/.../calendar/controller/calendar_screen_controller.dart
import 'dart:developer' as devtools show log;

import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/api/auth/auth_database/auth_service.dart';
import 'package:hexora/b-backend/api/socket/socket_manager.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/app_screen_manager.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_screen_logic/calendarUI_manager/calendar_ui_controller.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/logic/actions/event_actions_manager.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/bridge/event_display_manager.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/widgets/event_content_builder.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/add_event/UI/add_event_screen.dart';
import 'package:hexora/c-frontend/d-event-section/utils/color_manager.dart';
import 'package:hexora/d-stateManagement/event/event_data_manager.dart';
import 'package:hexora/d-stateManagement/group/group_management.dart';
import 'package:hexora/d-stateManagement/notification/notification_management.dart';
import 'package:hexora/d-stateManagement/user/presence_manager.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalendarScreenController {
  final BuildContext context;

  // UI helpers
  final AppScreenManager _screenManager = AppScreenManager();

  // Presence
  late PresenceManager _presenceManager;

  // Calendar wiring
  CalendarUIController? calendarUI;
  late EventDisplayManager _displayManager;
  EventActionManager? _eventActionManager;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  CalendarScreenController({required this.context}) {
    _initDisplayManager();
  }

  void _initDisplayManager() {
    final colorManager = ColorManager();
    final contentBuilder = EventContentBuilder(colorManager: colorManager);
    _displayManager = EventDisplayManager(null, builder: contentBuilder);
  }

  Future<void> initSockets() async {
    _presenceManager = context.read<PresenceManager>();
    final token = await context.read<AuthService>().getToken();
    if (token != null) {
      SocketManager().connect(token);
      SocketManager().on('presence:update', (data) {
        _presenceManager.updatePresenceList(data);
      });
    }
  }

  Future<void> loadData({Group? initialGroup}) async {
    final groupManagement = context.read<GroupManagement>();
    final userManagement = context.read<UserManagement>();
    final notifMgmt = context.read<NotificationManagement>();
    final eventData = context.read<EventDataManager>();

    try {
      _setLoading(true);

      // current group selection
      if (initialGroup != null) {
        groupManagement.currentGroup = initialGroup;
      } else if (groupManagement.currentGroup == null) {
        devtools.log("⚠️ No group provided and no currentGroup in manager.");
        _setLoading(false);
        return;
      }

      // refresh group from API
      final updatedGroup = await groupManagement.groupService
          .getGroupById(groupManagement.currentGroup!.id);
      groupManagement.currentGroup = updatedGroup;

      // emit presence (join)
      final me = userManagement.user;
      if (me != null) {
        SocketManager().emitUserJoin(
          userId: me.id,
          userName: me.userName,
          groupId: updatedGroup.id,
          photoUrl: me.photoUrl,
        );
      }

      // preload users for presence (offline known users)
      final allUsers = await userManagement.getUsersForGroup(updatedGroup);
      _presenceManager.setKnownUsers(allUsers);

      // role
      final userRole =
          updatedGroup.userRoles[userManagement.user?.userName ?? ''] ??
              'Member';

      // calendar controller + event actions
      calendarUI = CalendarUIController(
        eventDataManager: eventData,
        eventDisplayManager: _displayManager,
        userRole: userRole,
        groupManagement: groupManagement,
      );

      eventData.onExternalEventUpdate = calendarUI!.triggerCalendarHardRefresh;

      _eventActionManager = EventActionManager(
        groupManagement,
        userManagement,
        notifMgmt,
        eventDataManager: eventData,
      );

      _displayManager.setEventActionManager(_eventActionManager!);

      // initial events refresh
      await calendarUI!.eventDataManager.manualRefresh(context);
    } catch (e, s) {
      devtools.log("❌ Error initializing calendar: $e\n$s");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> handleAddEventPressed(BuildContext context, Group group) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEventScreen(group: group)),
    );
    if (added == true) {
      _setLoading(true);
      await loadData(initialGroup: group);
    }
  }

  // Presence consumer for widget
  List<UserPresence> buildPresenceFor(Group group) {
    final roleMap = {
      ...group.userRoles,
      ...?group.invitedUsers?.map((k, v) => MapEntry(k, v.role)),
    };
    return _presenceManager.getPresenceForGroup(group.userIds, roleMap);
  }

  void setScreenMetrics(BuildContext context) =>
      _screenManager.setScreenWidthAndCalendarHeight(context);

  void _setLoading(bool v) {
    _isLoading = v;
    // Up to the screen to call setState; or you can convert this to ChangeNotifier.
  }

  void dispose() {
    SocketManager().off('presence:update');
  }
}
