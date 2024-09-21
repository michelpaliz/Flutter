import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
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
