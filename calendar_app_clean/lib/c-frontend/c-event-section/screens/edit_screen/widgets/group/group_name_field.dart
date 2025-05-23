import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:flutter/material.dart';

class GroupNameField extends StatelessWidget {
  final String groupName;
  final ValueChanged<String> onNameChange;

  const GroupNameField({
    required this.groupName,
    required this.onNameChange,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller =
        TextEditingController(text: groupName);

    // Background for the input, adapts light ↔ dark
    final Color backgroundColor = ThemeColors.getLighterInputFillColor(context);

    // Contrast text & icon colors based on that background
    final Color contrastTextColor =
        ThemeColors.getContrastTextColor(context, backgroundColor);
    final Color iconColor = contrastTextColor;

    // Main text color for the field
    final Color textColor = ThemeColors.getTextColor(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomEditableTextField(
        controller: _controller,
        labelText: 'Group Name'.toUpperCase(),
        maxLength: 25,
        prefixIcon: Icons.group,
        backgroundColor: backgroundColor, // from ThemeColors
        iconColor: iconColor, // contrast against bg
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
