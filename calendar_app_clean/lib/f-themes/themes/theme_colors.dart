import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:flutter/material.dart';

class ThemeColors {
  static Color getTextColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.textPrimary
        : AppColors.black;
  }

  static Color getContrastTextColorForBackground(Color backgroundColor) {
    // Automatically decides between white or black text based on brightness
    return ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static Color getContrastTextColor(BuildContext context, Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  static Color getLighterInputFillColor(BuildContext context) {
    final base = getContainerBackgroundColor(context);
    final brightness = ThemeData.estimateBrightnessForColor(base);

    // Lighten or darken depending on theme
    return brightness == Brightness.dark
        ? base.withOpacity(0.4)
        : base.withOpacity(0.9);
  }

  static Color getTextColorWhite(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.textPrimary
        : AppColors.brown;
  }

  static Color getCardBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.surface
        : AppColors.yellow.withOpacity(0.8);
  }

  static Color getContainerBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.brown
        : AppColors.brown;
  }

  static Color getButtonTextColor(BuildContext context) {
    return getTextColor(context);
  }

  static Color getButtonBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.green
        : AppColors.brown;
  }

  static Color getSearchBarBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.surface
        : AppColors.yellowLight.withOpacity(0.8);
  }

  static Color getSearchBarIconColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.yellow
        : AppColors.brown;
  }

  static Color getSearchBarHintTextColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.textSecondary
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
        ? AppDarkColors.surface
        : Colors.white;
  }

  static Color getFilterChipGlowColor(BuildContext context, Color baseColor) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? baseColor.withOpacity(0.4)
        : _darkenColor(baseColor, 0.6);
  }

  static Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor().withOpacity(0.3);
  }
}
