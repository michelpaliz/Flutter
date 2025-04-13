import 'package:first_project/a-models/group_model/event-appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/auth/node_services/event_services.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> saveEditedEvent({
  required BuildContext context,
  required EventService eventService,
  required Event updatedData,
  required List<Event> eventList,
  required Group group,
  required GroupManagement groupManagement,
  required String? currentUserName,
  required bool startDateChanged,
}) async {
  final bool allowRepetitiveHours = true;

  bool isStartHourUnique = true;

  if (allowRepetitiveHours) {
    final startDateOnly = DateTime(
      updatedData.startDate.year,
      updatedData.startDate.month,
      updatedData.startDate.day,
    );

    isStartHourUnique = eventList.every((e) {
      final eventStartDateOnly = DateTime(
        e.startDate.year,
        e.startDate.month,
        e.startDate.day,
      );

      if (!startDateChanged && e.id == updatedData.id) return true;
      return eventStartDateOnly != startDateOnly;
    });
  }

  if (isStartHourUnique || !allowRepetitiveHours) {
    try {
      await eventService.updateEvent(updatedData.id, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.eventEdited)),
      );

      final updatedGroup =
          await groupManagement.groupService.getGroupById(group.id);
      groupManagement.currentGroup = updatedGroup;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.eventEditFailed)),
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.repetitionEvent),
        content: Text(AppLocalizations.of(context)!.repetitionEventInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
}
