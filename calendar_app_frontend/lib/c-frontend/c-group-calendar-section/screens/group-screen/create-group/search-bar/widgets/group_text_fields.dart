import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:calendar_app_frontend/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';

import '../controllers/create_group_controller.dart';

class GroupTextFields extends StatelessWidget {
  final GroupController controller;

  const GroupTextFields({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const int TITLE_MAX_LENGTH = 25;
    const int DESCRIPTION_MAX_LENGTH = 100;

    final Color backgroundColor = ThemeColors.getLighterInputFillColor(context);
    final Color contrastTextColor = ThemeColors.getContrastTextColor(
      context,
      backgroundColor,
    );
    final Color textColor = ThemeColors.getTextColor(context);

    // Instead of a custom brown background, reuse the adaptive fill
    final Color backgroundText = backgroundColor;
    // And icon tint matches the contrasting text color
    final Color iconColor = contrastTextColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group Name Header Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.groupNameLabel.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CustomEditableTextField(
            controller: controller.nameController,
            maxLength: TITLE_MAX_LENGTH,
            isMultiline: false,
            prefixIcon: Icons.group,
            backgroundColor: backgroundText,
            iconColor: iconColor,
            labelText: "",
            labelStyle: TextStyle(
              color: contrastTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            counterStyle: TextStyle(color: textColor), // 👈 you control it here
          ),
        ),

        const SizedBox(height: 12),

        // Group Description Header Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.descriptionLabel.toUpperCase(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CustomEditableTextField(
            controller: controller.descriptionController,
            maxLength: DESCRIPTION_MAX_LENGTH,
            isMultiline: true,
            prefixIcon: Icons.description,
            backgroundColor: backgroundText,
            iconColor: iconColor,
            labelText: "",
            labelStyle: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.normal,
            ),
            counterStyle: TextStyle(color: textColor), // 👈 you control it here
          ),
        ),
      ],
    );
  }
}
