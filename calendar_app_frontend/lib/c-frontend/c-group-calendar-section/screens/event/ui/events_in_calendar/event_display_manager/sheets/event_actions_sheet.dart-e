import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/c-frontend/c-group-calendar-section/screens/event/logic/actions/event_actions_manager.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/event_screen/event_detail.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';

class EventActionsSheet extends StatelessWidget {
  final Event event;
  final bool canEdit;
  final EventActionManager? actionManager;

  const EventActionsSheet({
    super.key,
    required this.event,
    required this.canEdit,
    required this.actionManager,
  });

  @override
  Widget build(BuildContext context) {
 
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(AppLocalizations.of(context)!.viewDetails),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventDetail(event: event)),
              );
            },
          ),
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(AppLocalizations.of(context)!.editEvent),
              onTap: () {
                Navigator.pop(context);
                actionManager?.editEvent(event, context);
              },
            ),
          if (canEdit)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                AppLocalizations.of(context)!.removeEvent,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await actionManager?.removeEvent(event, true);
              },
            ),
        ],
      ),
    );
  }
}
