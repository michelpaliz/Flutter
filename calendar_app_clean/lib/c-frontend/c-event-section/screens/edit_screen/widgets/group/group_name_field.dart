import 'package:first_project/f-themes/palette/app_colors.dart';
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

    // Define background color of the input
    final Color backgroundColor = ThemeColors.getLighterInputFillColor(context);

    // Now define the correct contrast text color based on that background
    final Color contrastTextColor =
        ThemeColors.getContrastTextColorForBackground(backgroundColor);
    final Color getColor = ThemeColors.getButtonTextColor(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomEditableTextField(
        controller: _controller,
        labelText: 'Group Name'.toUpperCase(),
        maxLength: 25,
        prefixIcon: Icons.group,
        backgroundColor:
            AppColors.brownLight.withOpacity(0.9), // 👈 Custom background
        iconColor: AppColors.yellowDark, // Optional override
        labelStyle: TextStyle(
          color: contrastTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        textStyle: TextStyle(
          color: getColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
