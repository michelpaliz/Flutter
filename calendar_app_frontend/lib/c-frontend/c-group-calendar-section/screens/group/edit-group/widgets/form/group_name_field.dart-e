import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:calendar_app_frontend/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class GroupNameField extends StatelessWidget {
  final String groupName;
  final ValueChanged<String> onNameChange;

  const GroupNameField({
    required this.groupName,
    required this.onNameChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // NOTE: creating a controller in build is okay here since we receive the source-of-truth (groupName) from parent.
    final controller = TextEditingController(text: groupName);

    final Color backgroundColor = ThemeColors.getLighterInputFillColor(context);
    final Color contrastTextColor =
        ThemeColors.getContrastTextColor(context, backgroundColor);
    final Color iconColor = contrastTextColor;
    final Color textColor = ThemeColors.getTextColor(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomEditableTextField(
        controller: controller,
        labelText: loc.groupNameLabel.toUpperCase(), // 🔤 localized
        maxLength: 25,
        prefixIcon: Icons.group,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        labelStyle: TextStyle(
          color: contrastTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        textStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
