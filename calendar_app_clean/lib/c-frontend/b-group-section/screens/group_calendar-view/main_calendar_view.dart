import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/1-calendar/calendarUI_manager/calendar_UI_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/b-event_display_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/c-event_actions_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/event_content_builder.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/add_event/functions/add_event_logic.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/add_event/functions/add_event_screen.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:first_project/d-stateManagement/event_data_manager.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainCalendarView extends StatefulWidget {
  final Group? group;
  const MainCalendarView({super.key, this.group});

  @override
  State<MainCalendarView> createState() => _MainCalendarViewState();
}

class _MainCalendarViewState extends State<MainCalendarView>
    with AddEventLogic {
  CalendarUIManager? _calendarUIManager;
  EventActionManager? _eventActionManager;
  late EventDisplayManager _displayManager;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    _loadData();
  }

  void _initializeManagers() {
    final colorManager = ColorManager();
    final contentBuilder = EventContentBuilder(colorManager: colorManager);
    _displayManager = EventDisplayManager(null, contentBuilder: contentBuilder);
  }

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

      _calendarUIManager = CalendarUIManager(
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
  Widget build(BuildContext context) {
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(
                    height: constraints.maxHeight * 0.8,
                    child: _calendarUIManager?.buildCalendar(
                          context,
                          height: constraints.maxHeight * 0.8,
                          width: constraints.maxWidth,
                        ) ??
                        const SizedBox(), // ✅ fallback if still null
                  ),
                  if (userRole == 'Administrator' ||
                      userRole == 'Co-Administrator')
                    ElevatedButton(
                      onPressed: () async {
                        // Push AddEvent under the same provider tree
                        final added = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (ctx) => AddEvent(group: currentGroup),
                          ),
                        );

                        // If the form returned `true`, refresh the calendar
                        if (added == true) {
                          setState(() => _isLoading = true);
                          await _initializeCalendar(
                              context.read<GroupManagement>());
                        }
                      },
                      child: const Text("Add Event"),
                    )
                ],
              ),
            );
          },
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
