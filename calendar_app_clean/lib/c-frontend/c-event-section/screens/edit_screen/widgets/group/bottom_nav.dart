import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:flutter/material.dart';

class BottomNavigationSection extends StatelessWidget {
  final VoidCallback onGroupUpdate;

  const BottomNavigationSection({
    required this.onGroupUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: onGroupUpdate,
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('Edit'),
        style: ButtonStyles.saucyButtonStyle(
          defaultBackgroundColor: ThemeColors.getButtonBackgroundColor(context),
          pressedBackgroundColor:
              ThemeColors.getContainerBackgroundColor(context),
          textColor: ThemeColors.getButtonTextColor(context),
          borderColor: ThemeColors.getButtonTextColor(context),
        ),
      ),
    );
  }
}
