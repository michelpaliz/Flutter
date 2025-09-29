import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:hexora/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class GroupDescriptionField extends StatelessWidget {
  final TextEditingController descriptionController;

  const GroupDescriptionField({required this.descriptionController, super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final Color backgroundColor = ThemeColors.getLighterInputFillColor(context);
    final Color contrastTextColor =
        ThemeColors.getContrastTextColor(context, backgroundColor);
    final Color iconColor = contrastTextColor;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomEditableTextField(
        controller: descriptionController,
        labelText: loc.groupDescriptionLabel.toUpperCase(), // 🔤 localized
        maxLength: 100,
        isMultiline: true,
        prefixIcon: Icons.description,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        labelStyle: TextStyle(
          color: contrastTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        textStyle: TextStyle(
          color: ThemeColors.getTextColor(context),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
