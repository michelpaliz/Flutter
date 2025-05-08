import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/1-calendar/1.2-calendar_ui_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/backend/event_data_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/a-event_ui_manger.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/b-event_display_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/c-event_actions_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/3-event/ui/event_content_builder.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/app_bar_manager.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/app_screen_manager.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/c-frontend/c-event-section/utils/event/color_manager.dart';
import 'package:flutter/material.dart';

class MainCalendarView extends StatefulWidget {
  final Group group;
  final EventService eventService;
  final ColorManager colorManager;
  final GroupManagement groupManagement; // Assuming GroupManagement is needed
  final UserManagement userManagement;
  final NotificationManagement notificationManagement;
  final String userRole;

  const MainCalendarView({
    required this.group,
    required this.eventService,
    required this.colorManager,
    required this.groupManagement,
    Key? key,
    required this.userManagement,
    required this.notificationManagement,
    required this.userRole,
  }) : super(key: key);

  @override
  _MainCalendarViewState createState() => _MainCalendarViewState();
}

class _MainCalendarViewState extends State<MainCalendarView> {
  final AppScreenManager _screenManager = AppScreenManager();
  final AppBarManager _appBarManager = AppBarManager();

  // Replace _calendarManager initialization to pass required parameters
  late CalendarUIManager _calendarManager;
  late EventDataManager _eventDataManager; // Declare without initializing yet
  late EventUIManager _eventUIManager; // Declare without initializing yet
  late final EventService _eventService; // Define EventService here
  late ColorManager _colorManager; // Assuming you have a ColorManager class
  late EventContentBuilder _contentBuilder; // Define your EventContentBuilder
  late GroupManagement _groupManagement; // Define your GroupManager class
  late EventActionManager _actionManager; // Define your EventActionManager
  String? _userRole; // Define userRole properly
  late Group _group;
  late UserManagement _userManagement;
  late NotificationManagement _notificationManagement;
  @override
  void initState() {
    super.initState();

    _group = widget.group;
    _groupManagement = widget.groupManagement;
    _userManagement = widget.userManagement;
    _notificationManagement = widget.notificationManagement;
    _userRole = widget.userRole;

    // Initialize services
    _eventService = widget.eventService; // Make sure to pass this correctly
    _colorManager = widget.colorManager; // Use the colorManager from widget
    _contentBuilder = EventContentBuilder(colorManager: _colorManager);

    // Initialize event data manager with actual events from the group
    _eventDataManager = EventDataManager(
      _group.calendar.events,
      group: _group,
      eventService: _eventService,
      groupManagement: _groupManagement,
    );

    // Initialize event UI components
    _actionManager = EventActionManager(
      _groupManagement,
      _userManagement,
      _notificationManagement,
      eventDataManager: _eventDataManager,
    );
    _eventUIManager = EventUIManager(
      colorManager: _colorManager,
      contentBuilder: _contentBuilder,
      actionManager: _actionManager,
      displayManager:
          EventDisplayManager(_actionManager, contentBuilder: _contentBuilder),
    );

    // Initialize the calendar UI manager with the necessary data
    _calendarManager = CalendarUIManager(
      _eventDataManager,
      // events: _eventDataManager.getEventsForDate(_group.calendar.events),
      events: _group.calendar.events,
      eventService: _eventService,
      eventDisplayManager: _eventUIManager.displayManager,
      userRole: _userRole!,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically set height and width based on the screen size
    _screenManager.setScreenWidthAndCalendarHeight(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Use the available height dynamically
              SizedBox(
                height: constraints.maxHeight * 0.8, // 80% of available height
                child: _calendarManager.buildCalendar(
                  context,
                  _screenManager.calendarHeight,
                  _screenManager.screenWidth,
                ),
              ),
              if (_userRole == 'Administrator' ||
                  _userRole == 'Co-Administrator')
                _actionManager.buildAddEventButton(context, _group),
              SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }
}
