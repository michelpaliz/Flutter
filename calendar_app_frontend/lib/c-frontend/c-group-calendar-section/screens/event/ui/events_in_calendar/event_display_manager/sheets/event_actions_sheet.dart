import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/logic/actions/event_actions_manager.dart';
import 'package:hexora/c-frontend/d-event-section/screens/event_screen/event_detail.dart';
import 'package:hexora/l10n/app_localizations.dart';

/// A stateless widget that displays a bottom sheet with actions related to an event.
///
/// Parameters:
/// - [event]: An instance of the `Event` class representing the event.
/// - [canEdit]: A boolean value indicating whether the user can edit the event.
/// - [actionManager]: An optional instance of the `EventActionManager` class for managing actions related to the event.
///
/// This widget is used in the `c-group-calendar-section` package of the Hexora application.
///
/// Returns a `SafeArea` widget containing a `Column` widget with `ListTile` widgets representing various actions on the event.
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
