import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
class TitleInputWidget extends StatelessWidget {
  final TextEditingController titleController;

  const TitleInputWidget({
    required this.titleController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: titleController,
      decoration:
          InputDecoration(labelText: AppLocalizations.of(context)!.title(15)),
      maxLength: 15,
    );
  }
}
