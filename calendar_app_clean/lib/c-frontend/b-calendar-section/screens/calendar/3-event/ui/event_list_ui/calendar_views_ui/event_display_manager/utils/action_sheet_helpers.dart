import 'package:first_project/a-models/group_model/event/event.dart';
import 'package:first_project/c-frontend/b-calendar-section/screens/calendar/3-event/actions/event_actions_manager.dart';
import 'package:flutter/material.dart';

import '../sheets/event_actions_sheet.dart';

void showEventActionsSheet({
  required BuildContext context,
  required Event event,
  required bool canEdit,
  required EventActionManager? actionManager,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => EventActionsSheet(
      event: event,
      canEdit: canEdit,
      actionManager: actionManager,
    ),
  );
}
