import 'package:hexora/f-themes/palette/app_colors.dart';
import 'package:hexora/f-themes/utilities/view-item-styles/app_bar/app_bar_styles.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme:
      AppBarStyles.defaultAppBarTheme(), // 👈 using reusable appbar style
  colorScheme:
      ColorScheme.fromSwatch(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ).copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
      ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppDarkColors.primary,
  scaffoldBackgroundColor: AppDarkColors.background,
  appBarTheme: AppBarStyles.defaultAppBarTheme(
    isDarkMode: true,
  ), // 👈 using reusable appbar style for dark mode
  colorScheme:
      ColorScheme.fromSwatch(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ).copyWith(
        primary: AppDarkColors.primary,
        secondary: AppDarkColors.secondary,
        surface: AppDarkColors.surface,
        onPrimary: AppDarkColors.textPrimary,
        onSecondary: AppDarkColors.textPrimary,
        onSurface: AppDarkColors.textPrimary,
      ),
);
