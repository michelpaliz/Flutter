import 'package:first_project/a-models/group.dart';
import 'package:first_project/b-backend/database_conection/node_services/event_services.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/app_bar_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/app_screen_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/a-calendar/b-calendar_ui_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/backend/d-event_data_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/2-event_display_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/3-event_actions_manager.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/a-event_ui_manger.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/event/ui/event_content_builder.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/styles/drawer-style-menu/my_drawer.dart';
import 'package:first_project/utilities/color_manager.dart';
import 'package:flutter/material.dart';


// class MainCalendarView extends StatefulWidget {
//   final Group group;

//   const MainCalendarView({required this.group, Key? key}) : super(key: key);

//   @override
//   _MainCalendarViewState createState() => _MainCalendarViewState();
// }

// class _MainCalendarViewState extends State<MainCalendarView> {
//   final AppScreenManager _screenManager = AppScreenManager();
//   final AppBarManager _appBarManager = AppBarManager();
  
//   // Replace _calendarManager initialization to pass required parameters
//   late CalendarUIManager _calendarManager;
//   late EventDataManager _eventDataManager; // Declare without initializing yet
//   late EventUIManager _eventUIManager; // Declare without initializing yet

//   late final EventService _eventService; // Define EventService here
//   late ColorManager _colorManager; // Assuming you have a ColorManager class
//   late EventContentBuilder _contentBuilder; // Define your EventContentBuilder
//   late EventActionManager _actionManager; // Define your EventActionManager
//   String? userRole; // Define userRole properly

//   @override
//   void initState() {
//     super.initState();
    
//     // Initialize EventService and any other required services
//     _eventService = EventService(); // Instantiate your EventService
//     _colorManager = ColorManager(); // Initialize ColorManager
//     _contentBuilder = EventContentBuilder(colorManager: null); // Initialize EventContentBuilder
//     _actionManager = EventActionManager(eventDataManager: null); // Initialize EventActionManager

//     // Initialize EventDataManager with necessary parameters
//     _eventDataManager = EventDataManager(
//       widget.group.calendar.events, // Assuming _events is defined and contains your list of events
//       group: widget.group,
//       eventService: _eventService,
//       groupManagement: GroupManagement(user: null), // Assuming you have a GroupManagement instance
//     );

//     // Initialize the EventUIManager with necessary parameters
//     _eventUIManager = EventUIManager(
//       colorManager: _colorManager,
//       contentBuilder: _contentBuilder,
//       actionManager: _actionManager,
//       displayManager: EventDisplayManager(contentBuilder: null), // Initialize or get your EventDisplayManager
//     );

//     // Initialize the calendar manager with required parameters
//     _calendarManager = CalendarUIManager(
//       _eventDataManager,
//       events: _eventDataManager.getEventsForDate(DateTime.now()), // Pass the events
//       eventService: _eventService, // Ensure you have an instance of EventService
//       eventDisplayManager: _eventUIManager, // Provide the event display manager
//       userRole: userRole ?? '', // Pass user role, default to empty string if null
//     );
//   }

//   void _reloadData() {
//     setState(() {
//       // Reload data logic here
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     _screenManager.setScreenWidthAndCalendarHeight(context);
//     return Scaffold(
//       appBar: _appBarManager.buildAppBar(context, _reloadData, widget.group),
//       drawer: MyDrawer(),
//       body: Column(
//         children: [
//           _calendarManager.buildCalendar(
//             context,
//             _screenManager.calendarHeight,
//             _eventDataManager.getEventsForDate(DateTime.now()) as double, // You may not need this if already passed
//           ),
//           if (userRole == 'Administrator' || userRole == 'Co-Administrator')
//             _buildAddEventButton(context),
//           SizedBox(height: 15),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddEventButton(BuildContext context) {
//     // Existing logic for Add Event Button
//     return ElevatedButton(
//       onPressed: () {
//         // Logic to add an event
//       },
//       child: Text('Add Event'),
//     );
//   }
// }
