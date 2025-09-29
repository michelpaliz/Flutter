import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NoteInputWidget extends StatelessWidget {
  final TextEditingController noteController;

  const NoteInputWidget({
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: noteController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.note(50),
      ),
      maxLength: 50,
    );
  }
}
