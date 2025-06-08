import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/c-frontend/c-event-section/screens/repetition_dialog/dialog/repetition_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

mixin AddEventDialogs {
  /// Shows the interactive RepetitionDialog for configuring recurrence logic.
  Future<List?> showRepetitionDialog(
    BuildContext context, {
    required DateTime selectedStartDate,
    required DateTime selectedEndDate,
    RecurrenceRule? initialRule,
  }) {
    return showDialog(
      context: context,
      builder: (context) => RepetitionDialog(
        selectedStartDate: selectedStartDate,
        selectedEndDate: selectedEndDate,
        initialRecurrenceRule: initialRule,
      ),
    );
  }

  /// Displays a simple error dialog for general event creation failure.
  void showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.event),
          content: Text(AppLocalizations.of(context)!.errorEventCreation),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Displays an error dialog when fetching group data fails.
  void showGroupFetchErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Group Error"),
          content: const Text(
              "Could not fetch the updated group. Please try again."),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Optional: Shows a static info-only dialog about repetition (not interactive).
  void showRepetitionInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.repetitionEvent),
          content: Text(AppLocalizations.of(context)!.repetitionEventInfo),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
