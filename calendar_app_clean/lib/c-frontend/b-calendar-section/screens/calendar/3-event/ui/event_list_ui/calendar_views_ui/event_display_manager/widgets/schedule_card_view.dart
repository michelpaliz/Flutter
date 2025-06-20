import 'package:first_project/a-models/group_model/event/event.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/actions/event_actions_manager.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/event_display_manager/utils/action_sheet_helpers.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/event_display_manager/utils/role_utils.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/event_display_manager/widgets/leading_icon.dart';
import 'package:first_project/l10n/AppLocalitationMethod.dart';
import 'package:flutter/material.dart';

class ScheduleCardView extends StatelessWidget {
  final Event event;
  final BuildContext contextRef;
  final Color textColor;
  final dynamic appointment;
  final Color cardColor;
  final EventActionManager? actionManager;
  final String userRole;

  const ScheduleCardView({
    super.key,
    required this.event,
    required this.contextRef,
    required this.textColor,
    required this.appointment,
    required this.cardColor,
    required this.actionManager,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizationsMethods.of(context)!;

    final formattedStartDate =
        '${loc.formatDate(event.startDate)} (${loc.formatHours(event.startDate)})';
    final formattedEndDate =
        '${loc.formatDate(event.endDate)} (${loc.formatHours(event.endDate)})';

    final dateTimeText = event.allDay
        ? '${loc.formatDate(event.startDate)} (All Day)'
        : '$formattedStartDate  /  $formattedEndDate';

    final recurrenceText =
        event.recurrenceRule != null ? event.recurrenceDescription : null;
    final canAdmin = canEdit(userRole);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            buildLeadingIcon(cardColor, event, size: 40),
            const SizedBox(width: 12),
            // ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ⬆️ DATE + TIME shown at the top
                  Text(
                    dateTimeText,
                    style: TextStyle(
                      fontSize: 11,
                      color: textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // ⬆️ Title
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration:
                          event.isDone ? TextDecoration.lineThrough : null,
                      color: textColor,
                    ),
                  ),

                  // ⬆️ Optional Description
                  if (event.description?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        event.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11, // Smaller
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ),

                  // ⬆️ Optional recurrence
                  if (recurrenceText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '🔁 $recurrenceText',
                        style: TextStyle(
                          fontSize: 12,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ───────────────────────────────────────────────
            IconButton(
              icon: Icon(Icons.more_vert, color: cardColor),
              onPressed: () {
                showEventActionsSheet(
                  context: context,
                  event: event,
                  canEdit: canAdmin,
                  actionManager: actionManager,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
