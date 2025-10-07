import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/core/event/domain/event_domain.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/auth_service.dart';
import 'package:hexora/b-backend/login_user/user/domain/presence_manager.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/notification/domain/notification_domain.dart';
import 'package:hexora/b-backend/socket/socket_manager.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/app_screen_manager.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_screen_logic/calendarUI_manager/calendar_ui_controller.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/logic/actions/event_actions_manager.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/bridge/event_display_manager.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/ui/events_in_calendar/widgets/event_content_builder.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/add_event/UI/add_event_screen.dart';
import 'package:hexora/c-frontend/d-event-section/utils/color_manager.dart';
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

  /// Initialize calendar view, group context, and events
  Future<void> loadData({Group? initialGroup}) async {
    final groupDomain = context.read<GroupDomain>();
    final userDomain = context.read<UserDomain>();
    final notifMgmt = context.read<NotificationDomain>();
    final eventData = context.read<EventDomain>();

    try {
      _setLoading(true);

      // 1️⃣ Set or confirm current group
      if (initialGroup != null) {
        groupDomain.currentGroup = initialGroup;
      } else if (groupDomain.currentGroup == null) {
        devtools.log("⚠️ No group provided and no currentGroup in manager.");
        _setLoading(false);
        return;
      }

      // 2️⃣ Refresh group from API (via repository)
      final updatedGroup = await groupDomain.groupRepository
          .getGroupById(groupDomain.currentGroup!.id);
      groupDomain.currentGroup = updatedGroup;

      // 3️⃣ Presence join emit
      final me = userDomain.user;
      if (me != null) {
        SocketManager().emitUserJoin(
          userId: me.id,
          userName: me.userName,
          groupId: updatedGroup.id,
          photoUrl: me.photoUrl,
        );
      }

      // 4️⃣ Load known users for presence
      final allUsers = await userDomain.getUsersForGroup(updatedGroup);
      _presenceManager.setKnownUsers(allUsers);

      // 5️⃣ Determine role
      final userRole = updatedGroup.userRoles[me?.id] ?? 'member';

      // 6️⃣ Initialize calendar + event display + actions
      calendarUI = CalendarUIController(
        eventDataManager: eventData,
        eventDisplayManager: _displayManager,
        userRole: userRole,
        groupDomain: groupDomain,
      );

      eventData.onExternalEventUpdate = calendarUI!.triggerCalendarHardRefresh;

      _eventActionManager = EventActionManager(
        groupDomain,
        userDomain,
        notifMgmt,
        eventDataManager: eventData,
      );

      _displayManager.setEventActionManager(_eventActionManager!);

      // 7️⃣ Refresh events initially
      await calendarUI!.eventDataManager.manualRefresh(context);
    } catch (e, s) {
      devtools.log("❌ Error initializing calendar: $e\n$s");
    } finally {
      _setLoading(false);
    }
  }

  /// Handle new event creation flow
  Future<void> handleAddEventPressed(BuildContext context, Group group) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddEventScreen(group: group)),
    );
    if (added == true) {
      _setLoading(true);
      await loadData(initialGroup: group);
    }
  }

  /// Presence consumer for widget
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
    // UI widget can rebuild by calling setState
  }

  void dispose() {
    SocketManager().off('presence:update');
  }
}
