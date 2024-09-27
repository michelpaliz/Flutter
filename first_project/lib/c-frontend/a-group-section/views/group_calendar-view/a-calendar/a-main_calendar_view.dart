import 'package:first_project/a-models/group.dart';
import 'package:first_project/b-backend/database_conection/node_services/event_services.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/a-calendar/b-calendar_ui_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/app_bar_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/app_screen_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/backend/d-event_data_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/a-event_ui_manger.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/b-event_display_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/c-event_actions_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/event_content_builder.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/styles/drawer-style-menu/my_drawer.dart';
import 'package:first_project/utilities/color_manager.dart';
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
    _groupManagement, _userManagement, _notificationManagement,
    eventDataManager: _eventDataManager,
  );
  _eventUIManager = EventUIManager(
    colorManager: _colorManager,
    contentBuilder: _contentBuilder,
    actionManager: _actionManager,
    displayManager: EventDisplayManager(_actionManager, contentBuilder: _contentBuilder),
  );

  // Initialize the calendar UI manager with the necessary data
  _calendarManager = CalendarUIManager(
    _eventDataManager,
    events: _eventDataManager.getEventsForDate(DateTime.now()),
    eventService: _eventService,
    eventDisplayManager: _eventUIManager.displayManager,
    userRole: _userRole!,
  );
}

  // @override
  // void initState() {
  //   super.initState();

  //   _group = widget.group;
  //   _groupManagement = widget.groupManagement;
  //   _userManagement = widget.userManagement;
  //   _notificationManagement = widget.notificationManagement;
  //   _userRole = widget.userRole;

  //   // Initialize EventService and any other required services
  //   _eventService = _eventService; // Instantiate your EventService
  //   _colorManager = ColorManager(); // Initialize ColorManager
  //   _contentBuilder = EventContentBuilder(
  //       colorManager: _colorManager); // Initialize EventContentBuilder
  //   _actionManager = EventActionManager(
  //       _groupManagement, _userManagement, _notificationManagement,
  //       eventDataManager: _eventDataManager); // Initialize EventActionManager

  //   // Initialize EventDataManager with necessary parameters
  //   _eventDataManager = EventDataManager(
  //     _group.calendar
  //         .events, // Assuming _events is defined and contains your list of events
  //     group: _group,
  //     eventService: _eventService,
  //     groupManagement:
  //         _groupManagement, // Assuming you have a GroupManagement instance
  //   );

  //   // Initialize the EventUIManager with necessary parameters
  //   _eventUIManager = EventUIManager(
  //     colorManager: _colorManager,
  //     contentBuilder: _contentBuilder,
  //     actionManager: _actionManager,
  //     displayManager: EventDisplayManager(_actionManager,
  //         contentBuilder:
  //             _contentBuilder), // Initialize or get your EventDisplayManager
  //   );

  //   // Initialize the calendar manager with required parameters
  //   _calendarManager = CalendarUIManager(_eventDataManager,
  //       events: _eventDataManager
  //           .getEventsForDate(DateTime.now()), // Pass the events
  //       eventService:
  //           _eventService, // Ensure you have an instance of EventService
  //       eventDisplayManager:
  //           _eventUIManager.displayManager, // Provide the event display manager
  //       userRole: _userRole! // Pass user role, default to empty string if null
  //       );
  // }

  @override
  @override
  Widget build(BuildContext context) {
    _screenManager.setScreenWidthAndCalendarHeight(
        context); // Dynamically set height and width

    return Scaffold(
      appBar:
          _appBarManager.buildAppBar(context, _eventDataManager, widget.group),
      drawer: MyDrawer(),
      body: Column(
        children: [
          _calendarManager.buildCalendar(
            context,
            _screenManager.calendarHeight, // Use dynamic calendar height
            _screenManager.screenWidth, // Use dynamic screen width
          ),
          if (_userRole == 'Administrator' || _userRole == 'Co-Administrator')
            _actionManager.buildAddEventButton(context, _group),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
