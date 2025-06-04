import 'package:first_project/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TitleInput extends StatelessWidget {
  final TextEditingController controller;

  const TitleInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomEditableTextField(
      controller: controller,
      labelText: AppLocalizations.of(context)!.title(15),
      maxLength: 15,
      prefixIcon: Icons.title, // Optional nice touch
    );
  }
}
