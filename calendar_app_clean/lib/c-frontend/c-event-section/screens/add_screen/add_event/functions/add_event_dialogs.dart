import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

mixin AddEventDialogs {
  void showRepetitionDialog(BuildContext context) {
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

  Widget buildRepetitionDialog(BuildContext context) {
    // You'll replace this with your actual `RepetitionDialog` widget
    return AlertDialog(
      title: const Text('Repetition settings'),
      content: const Text('Your repetition dialog implementation goes here.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop([null, false]),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop([/*rule*/ null, true]),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
