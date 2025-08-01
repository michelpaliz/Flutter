import 'package:calendar_app_frontend/f-themes/palette/app_colors.dart';
import 'package:flutter/material.dart';

class ThemeColors {
  static Color getTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.textPrimary
        : AppColors.textPrimary;
  }

  static Color getContrastTextColorForBackground(Color backgroundColor) {
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

    return brightness == Brightness.dark
        ? base.withOpacity(0.6) // ⬆️ more visible in dark mode
        : base.withOpacity(0.95); // ⬆️ slightly less transparent in light mode
  }

  static Color getTextColorWhite(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.textPrimary
        : AppColors.primary;
  }

  static Color getCardBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.surface
        : AppColors.surface;
  }

  static Color getContainerBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.background
        : AppColors.background;
  }

  static Color getButtonTextColor(BuildContext context) {
    return getTextColor(context);
  }

  static Color getButtonBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.primary
        : AppColors.primary;
  }

  static Color getSearchBarBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.surface
        : AppColors.surface.withOpacity(0.8);
  }

  static Color getSearchBarIconColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.secondary
        : AppColors.secondary;
  }

  static Color getSearchBarHintTextColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.textSecondary
        : AppColors.textSecondary;
  }

  static Color getCardShadowColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? Colors.black54
        : Colors.black26;
  }

  static Color getListTileBackgroundColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? AppDarkColors.surface
        : AppColors.white;
  }

  static Color getFilterChipGlowColor(BuildContext context, Color baseColor) {
    final theme = Theme.of(context);
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
