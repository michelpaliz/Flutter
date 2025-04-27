import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:flutter/material.dart';

class ThemeColors {
  static Color getTextColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? Colors.white : AppColors.brown;
  }

  static Color getCardBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.green.withOpacity(0.8)
        : AppColors.yellow.withOpacity(0.8);
  }

  static Color getContainerBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.brown.withOpacity(0.8)
        : AppColors.yellow.withOpacity(0.6);
  }

  static Color getButtonTextColor(BuildContext context) {
    return getTextColor(context);
  }

  static Color getButtonBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.green
        : AppColors.blue.withOpacity(0.8);
  }
}
