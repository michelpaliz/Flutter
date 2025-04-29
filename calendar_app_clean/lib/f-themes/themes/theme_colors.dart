import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:flutter/material.dart';

class ThemeColors {
  static Color getTextColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  static Color getTextColorWHite(BuildContext context) {
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
        ? AppColors.greenDark
        : AppColors.brown;
  }

  static Color getSearchBarBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.brownDark.withOpacity(0.8)
        : AppColors.yellowLight.withOpacity(0.8);
  }

  static Color getSearchBarIconColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.yellow
        : AppColors.brown;
  }

  static Color getSearchBarHintTextColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppColors.yellow
        : AppColors.brownDark;
  }

  static Color getCardShadowColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.black54
        : Colors.black26;
  }

  static Color getListTileBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.white;
  }

  static Color getFilterChipGlowColor(BuildContext context, Color baseColor) {
    ThemeData theme = Theme.of(context);

    if (theme.brightness == Brightness.dark) {
      // Dark mode → keep the strong colorful glow
      return baseColor.withOpacity(0.4);
    } else {
      // Light mode → darken the base color to create a serious glow
      return _darkenColor(baseColor, 0.6); // darken by 60%
    }
  }

  static Color _darkenColor(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor().withOpacity(0.3); // control glow opacity
  }
}
