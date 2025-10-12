import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/event/logic/actions/event_actions_manager.dart';

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

/// Returns true if the user can edit or delete events.
bool canEdit(String userRole) {
  return userRole == 'Administrator' || userRole == 'Co-Administrator';
}
