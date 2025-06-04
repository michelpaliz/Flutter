import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/c-frontend/routes/appRoutes.dart';
import 'package:first_project/d-stateManagement/event/event_data_manager.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/notification/notification_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';

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

                if (updatedGroup != null &&
                    updatedGroup is Group &&
                    updatedGroup.calendar.events.length !=
                        group.calendar.events.length) {
                  groupManagement.updateGroup(updatedGroup, userManagement);
                }
              }),
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
