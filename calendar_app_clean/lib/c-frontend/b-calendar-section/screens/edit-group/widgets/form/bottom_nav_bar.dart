import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavigationSection extends StatelessWidget {
  final VoidCallback onGroupUpdate;

  const BottomNavigationSection({
    required this.onGroupUpdate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = ThemeColors.getButtonBackgroundColor(context);
    final Color contrastTextColor =
        ThemeColors.getContrastTextColorForBackground(backgroundColor);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: onGroupUpdate,
        icon: Icon(Icons.group_add_rounded, color: contrastTextColor),
        label: Text(
          AppLocalizations.of(context)!.save,
          style: TextStyle(color: contrastTextColor),
        ),
        style: ButtonStyles.saucyButtonStyle(
          defaultBackgroundColor: backgroundColor,
          pressedBackgroundColor:
              ThemeColors.getContainerBackgroundColor(context),
          textColor: contrastTextColor,
          borderColor: contrastTextColor,
        ),
      ),
    );
  }
}
