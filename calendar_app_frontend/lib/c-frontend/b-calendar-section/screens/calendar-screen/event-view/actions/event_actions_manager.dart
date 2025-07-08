import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/notification_model/userInvitation_status.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/edit_screen/UI/edit_event_screen.dart';
import 'package:calendar_app_frontend/c-frontend/routes/appRoutes.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventActionManager {
  final EventDataManager eventDataManager;
  final GroupManagement groupManagement;
  final UserManagement userManagement;
  final NotificationManagement notificationManagement;
  Map<String, UserInviteStatus>? invitedUsers;

  EventActionManager(
    this.groupManagement,
    this.userManagement,
    this.notificationManagement, {
    required this.eventDataManager,
  });

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
              final added = await Navigator.pushNamed(
                context,
                AppRoutes.addEvent,
                arguments: group,
              );

              if (added != null) {
                // Optionally refetch group info if needed
                final refreshedGroup = await groupManagement.groupService
                    .getGroupById(group.id);
                groupManagement.updateGroup(refreshedGroup, userManagement);

                // Refresh the events directly
                await eventDataManager.manualRefresh();
              }
            },
          ),
        ),
      ),
    );
  }

  void editEvent(Event event, BuildContext context) {
    final sharedEventDataManager = eventDataManager; // use existing instance

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Provider<EventDataManager>.value(
          value: sharedEventDataManager,
          child: EditEventScreen(event: event),
        ),
      ),
    );
  }

  // Show the removal confirmation dialog and handle the removal logic
  Future<bool> removeEvent(Event event, bool confirmed) async {
    if (confirmed) {
      await eventDataManager.removeGroupEvents(event: event);
    }
    return confirmed;
  }
}
