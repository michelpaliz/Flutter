import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/c-frontend/b-group-section/views/group_calendar-view/3-event/backend/event_data_manager.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/utilities/enums/routes/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
// >>>>>>> 920ffaf214b3836fbba7661bd9bf19e4c7f3114b

// The EventActionManager class is primarily focused on handling UI-related actions for events, with direct delegation to EventDataManager for data-related operations. It provides methods for managing event-related actions, like adding, editing, and removing events. Here's a breakdown of its role compared to the other classes:
// 1. Primary Purpose

//     EventActionManager:
//         Manages the user actions related to events, such as adding, editing, or removing events.
//         It acts as an intermediary between the UI and EventDataManager, ensuring that user-triggered actions like event updates or deletions are handled by the appropriate backend logic.
//         It focuses on triggering event actions from the UI and handling the flow between UI navigation and backend operations.

// 2. Key Responsibilities

//     User Action Handling:
//         Provides a button for adding events (buildAddEventButton) and manages user navigation to the "Add Event" screen.
//         Handles editing events (editEvent) by navigating to the "Edit Event" screen and updating the event through EventDataManager.
//         Manages event deletion (removeEvent) by confirming and then calling EventDataManager to remove the event from the backend and the local data source.

//     Delegation to EventDataManager:
//         While EventActionManager deals with the UI-triggered actions, it doesn’t handle the actual data manipulation. Instead, it delegates data operations like updating or removing events to EventDataManager.
//         This allows EventActionManager to focus on user interaction logic while offloading the data operations to EventDataManager.

// 3. Comparison with EventDisplayManager

//     EventDisplayManager:
//         Manages the UI layout and display of events (building event details, managing swipe actions).
//         Deals with permissions (checking if a user has the necessary role to edit or delete events).
//         It handles how events are visually represented and how users can interact with them (such as tapping or dismissing).

//     EventActionManager:
//         Focuses on handling the actions triggered by the user, such as adding or editing events.
//         It does not build the event's visual representation, but instead, focuses on the flow of actions related to events (e.g., navigating to the edit screen or adding a new event).
//         Delegates the actual data modifications (add, edit, delete) to EventDataManager.

// 4. Interaction with EventDataManager

//     EventActionManager heavily relies on EventDataManager to perform all data-related tasks:
//         When an event is added or edited, it navigates to the appropriate UI (via Navigator.pushNamed) and then calls eventDataManager.updateEvent to update the event in the backend.
//         When an event is removed, it calls eventDataManager.removeGroupEvents to delete the event from both the backend and local state.

//     Separation of Concerns: EventActionManager is concerned with user actions (e.g., navigating to different screens, confirming removals), while EventDataManager is concerned with the data layer (e.g., interacting with the database or service to persist changes).

// 5. UI Handling and User Flow

//     EventActionManager primarily handles navigation and user input:
//         It provides a UI button for adding events (buildAddEventButton), and handles the navigation to the appropriate screens for adding or editing events.
//         It is responsible for managing the flow of event-related actions (e.g., confirming a removal, passing the result back from the event editing screen).

//     EventDisplayManager, on the other hand, handles the visual representation of event details and user interaction (e.g., displaying event information, handling taps or swipes).

// 6. Interfacing with the App's UI

//     EventActionManager interacts with the app's navigation system to handle adding, editing, and removing events.
//         It ensures that the right screens are displayed when a user wants to modify events (e.g., adding or editing an event).
//         It ensures that any changes made on those screens (like adding a new event) are reflected in the app by updating the group or event data via EventDataManager.

class EventActionManager {
  final EventDataManager eventDataManager;
  final GroupManagement groupManagement;
  final UserManagement userManagement;
  final NotificationManagement notificationManagement;
  Map<String, UserInviteStatus>? invitedUsers;

  EventActionManager(
      this.groupManagement, this.userManagement, this.notificationManagement,
      {required this.eventDataManager});

  // Build the add event button
  Widget buildAddEventButton(BuildContext context, Group group) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(25),
          ),
          width: 50,
          height: 50,
          child: IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 25),
            onPressed: () async {
              final updatedGroup = await Navigator.pushNamed(
                context,
                AppRoutes.addEvent,
                arguments: group,
              );

              if (updatedGroup != null && updatedGroup is Group) {
                groupManagement.updateGroup(updatedGroup, userManagement,
                    notificationManagement, invitedUsers);
              }
            },
          ),
        ),
      ),
    );
  }

  // Edit event method using EventDataManager
  void editEvent(Event event, BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.editEvent,
      arguments: event,
    ).then((result) {
      if (result != null && result is Event) {
        eventDataManager
            .updateEvent(result); // Use EventDataManager to update the event
      }
    });
  }

  // Show the removal confirmation dialog and handle the removal logic
  Future<bool> removeEvent(Event event, bool confirmed) async {
    if (confirmed) {
      await eventDataManager.removeGroupEvents(event: event);
    }
    return confirmed;
  }
}
