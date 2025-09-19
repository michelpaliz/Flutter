import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:calendar_app_frontend/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';

import '../controllers/group_controller.dart';

class SaveGroupButton extends StatelessWidget {
  final GroupController controller;

  const SaveGroupButton({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeColors.getButtonBackgroundColor(context);
    final contrastTextColor = ThemeColors.getContrastTextColorForBackground(
      backgroundColor,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ButtonStyles.buttonWithIcon(
        iconData: Icons.group_add,
        label: AppLocalizations.of(context)!.saveGroup,
        style: ButtonStyles.saucyButtonStyle(
          defaultBackgroundColor: backgroundColor,
          pressedBackgroundColor: ThemeColors.getContainerBackgroundColor(
            context,
          ),
          textColor: contrastTextColor,
          borderColor: contrastTextColor,
          borderRadius: 12.0,
          padding: 14.0,
          fontSize: 17.0,
          fontWeight: FontWeight.bold,
        ),
        onPressed: controller.submitGroupFromUI,
      ),
    );
  }
}
