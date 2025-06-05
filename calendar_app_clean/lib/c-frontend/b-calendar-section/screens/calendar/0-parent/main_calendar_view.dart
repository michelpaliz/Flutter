import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/0-parent/add_event_button.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/1-calendar/calendarUI_manager/calendar_ui_controller.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/actions/event_actions_manager.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/widgets/event_content_builder.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/widgets/event_display_manager.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/app_screen_manager.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/add_event/UI/add_event_screen.dart';
import 'package:first_project/c-frontend/c-event-section/screens/actions/add_screen/add_event/functions/add_event_logic.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:first_project/d-stateManagement/event/event_data_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/notification/notification_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainCalendarView extends StatefulWidget {
  final Group? group;
  const MainCalendarView({super.key, this.group});

  @override
  State<MainCalendarView> createState() => _MainCalendarViewState();
}

class _MainCalendarViewState extends AddEventLogic<MainCalendarView> {
  final AppScreenManager _screenManager = AppScreenManager();
  CalendarUIController? _calendarUIManager;
  EventActionManager? _eventActionManager;
  late EventDisplayManager _displayManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    _loadData();
  }

  // void _initializeManagers() {
  //   final colorManager = ColorManager();
  //   final contentBuilder = EventContentBuilder(colorManager: colorManager);
  //   _displayManager = EventDisplayManager(null, contentBuilder: contentBuilder);
  // }

  void _initializeManagers() {
    final colorManager = ColorManager();
    final contentBuilder = EventContentBuilder(colorManager: colorManager);

    // Use `builder:` because that's what the constructor expects now
    _displayManager = EventDisplayManager(
      null,
      builder: contentBuilder,
    );
  }

  /// Loads the group data and initializes the calendar.
  ///
  /// If the group is not available, it displays a centered text message.
  ///
  /// If the user has the necessary permissions, it displays an "Add Event"
  /// button below the calendar.
  ///
  /// When the button is pressed, it navigates to the add event screen and
  /// refreshes the calendar when returning.
  ///
  Future<void> _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final groupManagement = context.read<GroupManagement>();

      injectDependencies(
        groupMgmt: groupManagement,
        userMgmt: context.read<UserManagement>(),
        notifMgmt: context.read<NotificationManagement>(),
      );

      // 1. First try to use the widget.group if provided
      if (widget.group != null) {
        groupManagement.currentGroup = widget.group;
      }
      // 2. If no group available, try to fetch it
      else if (groupManagement.currentGroup == null) {
        // You might need to pass groupId through constructor if widget.group is null
        debugPrint(
            "⚠️ No group provided and GroupManagement has no current group");
        setState(() => _isLoading = false);
        return;
      }

      await _initializeCalendar(groupManagement);
    });
  }

  /// Initializes the calendar with the given [GroupManagement].
  ///
  /// This does the following:
  ///
  /// 1. Force refreshes the group data.
  /// 2. Creates a new [CalendarUIController] instance with the shared [EventDataManager].
  /// 3. Creates a new [EventActionManager] instance with the shared [EventDataManager].
  /// 4. Sets the [EventActionManager] instance in the [EventDisplayManager].
  /// 5. Force refreshes the events in the calendar.
  ///
  /// If any error occurs, it's caught and [_isLoading] is set to false.
  ///
  Future<void> _initializeCalendar(GroupManagement groupManagement) async {
    try {
      setState(() => _isLoading = true);

      // Force refresh the group data
      final updatedGroup = await groupManagement.groupService
          .getGroupById(groupManagement.currentGroup!.id);
      groupManagement.currentGroup = updatedGroup;

      final userManagement = context.read<UserManagement>();
      final userRole =
          updatedGroup.userRoles[userManagement.user?.userName ?? ''] ??
              'Member';

// ✅ Using the shared EventDataManager via Provider to sync logic and UI
      final sharedEventDataManager = context.read<EventDataManager>();

      _calendarUIManager = CalendarUIController(
        eventDataManager: sharedEventDataManager,
        eventDisplayManager: _displayManager,
        userRole: userRole,
        groupManagement: groupManagement,
      );

      _eventActionManager = EventActionManager(
        groupManagement,
        userManagement,
        context.read<NotificationManagement>(),
        eventDataManager: sharedEventDataManager,
      );

      if (_eventActionManager != null) {
        _displayManager.setEventActionManager(_eventActionManager!);
      }

      // Force refresh the events in the calendar
      await _calendarUIManager!.eventDataManager.manualRefresh();

      setState(() => _isLoading = false);
      debugPrint(
          "✅ Calendar initialized with ${updatedGroup.calendar.events.length} events");
    } catch (e, stack) {
      debugPrint("❌ Error initializing calendar: $e");
      debugPrintStack(stackTrace: stack);
      setState(() => _isLoading = false);
    }
  }

  @override

  /// Builds the main calendar view based on the currently selected group.
  ///
  /// If the group is not available, it displays a centered text message.
  ///
  /// If the user has the necessary permissions, it displays an "Add Event"
  /// button below the calendar.
  ///
  /// When the button is pressed, it navigates to the add event screen and
  /// refreshes the calendar when returning.
  ///
  /// The calendar is built using the [_calendarUIManager], which is
  /// initialized in [_initializeCalendar].
  ///
  @override
  Widget build(BuildContext context) {
    _screenManager.setScreenWidthAndCalendarHeight(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final groupManagement = context.read<GroupManagement>();
    if (groupManagement.currentGroup == null) {
      return const Scaffold(
        body: Center(child: Text("No group available")),
      );
    }

    final currentGroup = groupManagement.currentGroup!;
    final userRole = currentGroup
            .userRoles[context.read<UserManagement>().user?.userName ?? ''] ??
        'Member';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(currentGroup.name),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // Calendar expands to fill available space
              Expanded(
                child: _calendarUIManager?.buildCalendar(
                      context,
                      // height: double.infinity,
                      // width: double.infinity,
                    ) ??
                    const SizedBox(),
              ),

              // Add Event button at bottom
              if (userRole == 'Administrator' || userRole == 'Co-Administrator')
                AddEventButton(
                  isVisible: true,
                  onPressed: () async {
                    final added = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => AddEventScreen(group: currentGroup),
                      ),
                    );
                    if (added == true) {
                      setState(() => _isLoading = true);
                      await _initializeCalendar(
                        context.read<GroupManagement>(),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    disposeControllers();
  }
}
