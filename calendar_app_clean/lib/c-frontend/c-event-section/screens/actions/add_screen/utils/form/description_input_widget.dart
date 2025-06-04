import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
class DescriptionInputWidget extends StatelessWidget {
  final TextEditingController descriptionController;

  const DescriptionInputWidget({
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: descriptionController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.description(100),
      ),
      maxLength: 100,
    );
  }
}
