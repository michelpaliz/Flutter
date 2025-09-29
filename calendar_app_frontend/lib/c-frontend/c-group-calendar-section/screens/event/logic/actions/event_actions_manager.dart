import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/edit_screen/UI/edit_event_screen.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/d-stateManagement/event/event_data_manager.dart';
import 'package:hexora/d-stateManagement/group/group_management.dart';
import 'package:hexora/d-stateManagement/notification/notification_management.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
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
                final refreshedGroup =
                    await groupManagement.groupService.getGroupById(group.id);
                groupManagement.updateGroup(refreshedGroup, userManagement);

                // Refresh the events directly
                await eventDataManager.manualRefresh(context);
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

  /// helper that strips any `-timestamp` suffix you added client-side
  String baseId(String id) => id.split('-').first;

  Future<bool> removeEvent(Event ev, bool confirmed) async {
    if (!confirmed) return false; // swipe was cancelled

    final mongoId = baseId(ev.id); // <-- real _id
    debugPrint('🗑️  [UI] removeEvent for ${ev.id}  →  $mongoId');

    try {
      await eventDataManager.deleteEvent(mongoId);
      debugPrint('✅  [UI] deleteEvent completed for $mongoId');
      return true;
    } catch (e, st) {
      debugPrint('❌  [UI] deleteEvent threw: $e');
      debugPrintStack(stackTrace: st);
      // TODO: ScaffoldMessenger.of(context).showSnackBar(...)
      return false;
    }
  }
}
