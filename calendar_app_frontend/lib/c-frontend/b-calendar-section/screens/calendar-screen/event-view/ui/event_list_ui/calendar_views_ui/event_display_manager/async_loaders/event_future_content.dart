import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar-screen/event-view/actions/event_actions_manager.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../widgets/event_details_card.dart';

class EventFutureContentWidget extends StatelessWidget {
  final Event event; // ✅ Updated from String to Event
  final Color textColor;
  final CalendarAppointmentDetails details;
  final String userRole;
  final EventActionManager? actionManager;
  final ColorManager colorManager;

  const EventFutureContentWidget({
    super.key,
    required this.event, // ✅ Corrected constructor param
    required this.textColor,
    required this.details,
    required this.userRole,
    required this.actionManager,
    required this.colorManager,
  });

  @override
  Widget build(BuildContext context) {
    if (actionManager == null) return const SizedBox.shrink();

    return SizedBox(
      width: details.bounds.width,
      height: details.bounds.height,
      child: FutureBuilder<Event?>(
        future: actionManager!.eventDataManager.fetchEvent(event.id), // ✅ uses Event
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && snapshot.data != null) {
            return EventDetailsCard(
              event: snapshot.data!,
              contextRef: context,
              textColor: textColor,
              appointment: details.appointments.first,
              userRole: userRole,
              actionManager: actionManager,
              colorManager: colorManager,
            );
          } else {
            return Text(
              'No event found',
              style: TextStyle(fontSize: 14, color: textColor),
            );
          }
        },
      ),
    );
  }
}
