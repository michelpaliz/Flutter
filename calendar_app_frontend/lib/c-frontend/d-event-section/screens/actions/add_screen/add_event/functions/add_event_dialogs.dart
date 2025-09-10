import 'package:calendar_app_frontend/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/c-frontend/d-event-section/screens/repetition_dialog/dialog/repetition_dialog.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

mixin AddEventDialogs {
  /// Shows the interactive RepetitionDialog for configuring recurrence logic.
  Future<List?> showRepetitionDialog(
    BuildContext context, {
    required DateTime selectedStartDate,
    required DateTime selectedEndDate,
    LegacyRecurrenceRule? initialRule,
  }) {
    return showDialog<List?>(
      context: context,
      builder: (context) => RepetitionDialog(
        selectedStartDate: selectedStartDate,
        selectedEndDate: selectedEndDate,
        initialRecurrenceRule: initialRule,
        // onRemoveRecurrence: () async {
        //   final confirmed = await showDialog<bool>(
        //     context: context,
        //     builder: (_) => AlertDialog(
        //       title: Text(AppLocalizations.of(context)!.confirm),
        //       content: Text(AppLocalizations.of(context)!.removeRecurrenceConfirm),
        //       actions: [
        //         TextButton(
        //           onPressed: () => Navigator.pop(context, false),
        //           child: Text(AppLocalizations.of(context)!.cancel),
        //         ),
        //         ElevatedButton(
        //           onPressed: () => Navigator.pop(context, true),
        //           child: Text(AppLocalizations.of(context)!.remove),
        //         ),
        //       ],
        //     ),
        //   );

        //   if (confirmed == true) {
        //     Navigator.of(context).pop([null]); // 👈 Return null to signal removal
        //   }
        // },
      ),
    );
  }

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

  void showGroupFetchErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Group Error"),
          content: const Text(
            "Could not fetch the updated group. Please try again.",
          ),
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
