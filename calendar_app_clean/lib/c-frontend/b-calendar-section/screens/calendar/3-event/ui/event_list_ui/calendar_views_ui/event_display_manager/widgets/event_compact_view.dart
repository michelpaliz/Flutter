import 'package:first_project/a-models/group_model/event/event.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/actions/event_actions_manager.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/widgets/event_date_time.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/event_display_manager/utils/role_utils.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/widgets/event_title_row.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventCompactView extends StatelessWidget {
  final Event event;
  final CalendarAppointmentDetails details;
  final Color textColor;
  final EventActionManager? actionManager;
  final ColorManager colorManager;
  final String userRole; // ➊ pass in

  const EventCompactView({
    super.key,
    required this.event,
    required this.details,
    required this.textColor,
    required this.colorManager,
    required this.userRole, // ➊
    this.actionManager,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = colorManager.getColor(event.eventColorIndex);
    final canEditEvent =
        canEdit(userRole); // ➋ no longer actionManager?.userRole

    return GestureDetector(
      onTap: () {
        if (canEditEvent) actionManager?.editEvent(event, context);
      },
      child: Container(
        width: details.bounds.width,
        height: details.bounds.height,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: cardColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EventDateTimeRow(event: event, textColor: textColor),
            EventTitleRow(
              event: event,
              textColor: textColor,
              colorManager: colorManager, // ➌ use the one we received
            ),
            if (event.description?.isNotEmpty ?? false)
              Text(
                event.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontSize: 11, color: textColor.withOpacity(0.7)),
              ),
          ],
        ),
      ),
    );
  }
}
