import 'package:first_project/a-models/group_model/event/event.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/actions/event_actions_manager.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/widgets/event_date_time.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/event_display_manager/utils/action_sheet_helpers.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/event_display_manager/utils/role_utils.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/event_display_manager/widgets/leading_icon.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/ui/event_list_ui/calendar_views_ui/widgets/event_title_row.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:flutter/material.dart';

class EventDetailsCard extends StatelessWidget {
  final Event event;
  final BuildContext contextRef;
  final Color textColor;
  final dynamic appointment;
  final String userRole;
  final EventActionManager? actionManager;
  final ColorManager colorManager; // ✅ new

  const EventDetailsCard({
    super.key,
    required this.event,
    required this.contextRef,
    required this.textColor,
    required this.appointment,
    required this.userRole,
    required this.actionManager,
    required this.colorManager, // ✅ new
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = colorManager.getColor(event.eventColorIndex);
    final canAdmin = canEdit(userRole);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Dismissible(
        key: Key(appointment.id),
        direction:
            canAdmin ? DismissDirection.endToStart : DismissDirection.none,
        background: _buildDeleteBackground(),
        confirmDismiss: (_) async {
          if (!canAdmin || actionManager == null) return false;
          return await actionManager!.removeEvent(event, true);
        },
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                buildLeadingIcon(cardColor, event), // ✅ working now
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EventDateTimeRow(event: event, textColor: textColor),
                      EventTitleRow(
                        event: event,
                        textColor: textColor,
                        colorManager: colorManager, // ✅ use param
                      ),
                      if (event.description?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            event.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
        ),
      ),
    );
  }

  Widget _buildDeleteBackground() => Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white, size: 20),
      );
}
