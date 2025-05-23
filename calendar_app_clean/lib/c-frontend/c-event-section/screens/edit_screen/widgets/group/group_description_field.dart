import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:flutter/material.dart';

class GroupDescriptionField extends StatelessWidget {
  final TextEditingController descriptionController;

  const GroupDescriptionField({
    required this.descriptionController,
  });
@override
Widget build(BuildContext context) {
  // Use our ThemeColors utilities for background & text
  final Color backgroundColor = ThemeColors.getLighterInputFillColor(context);
  final Color contrastTextColor =
      ThemeColors.getContrastTextColor(context, backgroundColor);
  // Icon can follow the same contrast logic
  final Color iconColor =
      ThemeColors.getContrastTextColor(context, backgroundColor);

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: CustomEditableTextField(
      controller: descriptionController,
      labelText: 'Group Description'.toUpperCase(),
      maxLength: 100,
      isMultiline: true,
      prefixIcon: Icons.description,
      backgroundColor: backgroundColor,       // from ThemeColors
      iconColor: iconColor,                   // contrast against bg
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
