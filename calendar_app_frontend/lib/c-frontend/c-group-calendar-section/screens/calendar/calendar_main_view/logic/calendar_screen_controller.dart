// calendar_screen_controller.dart
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/group_mng_flow/event/domain/event_domain.dart';
import 'package:hexora/b-backend/group_mng_flow/event/socket/socket_manager.dart';
import 'package:hexora/b-backend/group_mng_flow/group/domain/group_domain.dart';
import 'package:hexora/b-backend/auth_user/auth/auth_database/auth_service.dart';
import 'package:hexora/b-backend/auth_user/user/presence_domain.dart';
import 'package:hexora/b-backend/auth_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/notification/domain/notification_domain.dart';
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
  late PresenceDomain _presenceManager;

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
    _presenceManager = context.read<PresenceDomain>();
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
    final eventDomain = context.read<EventDomain>();

    try {
      _setLoading(true);

      // 1) Set or confirm current group
      if (initialGroup != null) {
        groupDomain.currentGroup =
            initialGroup; // safe setter (defers notify if needed)
      } else if (groupDomain.currentGroup == null) {
        devtools.log("⚠️ No group provided and no currentGroup in manager.");
        _setLoading(false);
        return;
      }

      // 2) Refresh group from API (via repository)
      final updatedGroup = await groupDomain.groupRepository
          .getGroupById(groupDomain.currentGroup!.id);
      groupDomain.currentGroup = updatedGroup;

      // 3) Presence join emit
      final me = userDomain.user;
      if (me != null) {
        SocketManager().emitUserJoin(
          userId: me.id,
          userName: me.userName,
          groupId: updatedGroup.id,
          photoUrl: me.photoUrl,
        );
      }

      // 4) Load known users for presence
      final allUsers = await userDomain.getUsersForGroup(updatedGroup);
      _presenceManager.setKnownUsers(allUsers);

      // 5) Determine role
      final userRole = updatedGroup.userRoles[me?.id] ?? 'member';

      // 6) Initialize calendar + event display + actions
      calendarUI = CalendarUIController(
        eventDomain: eventDomain, // ✔ matches new ctor param name
        eventDisplayManager: _displayManager,
        userRole: userRole,
        groupDomain: groupDomain,
      );

      // Keep the UI’s action manager in sync with the same EventDomain instance
      _eventActionManager = EventActionManager(
        groupDomain,
        userDomain,
        notifMgmt,
        eventDomain: eventDomain,
      );
      _displayManager.setEventActionManager(_eventActionManager!);

      // 7) Initial event refresh through the domain (named arg + no "hard" param)
      await calendarUI!.eventDomain.manualRefresh(context);
      // UI refresh is handled in CalendarUIController’s stream listener; no direct “hard refresh” call here.
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
    final roleMap = {...group.userRoles};
    return _presenceManager.getPresenceForGroup(group.userIds, roleMap);
  }

  void setScreenMetrics(BuildContext context) =>
      _screenManager.setScreenWidthAndCalendarHeight(context);

  void _setLoading(bool v) {
    _isLoading = v;
    // UI widget can rebuild by calling setState in the widget layer
  }

  void dispose() {
    SocketManager().off('presence:update');
  }
}
