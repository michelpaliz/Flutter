import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/app_bar/app_bar_styles.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme:
      AppBarStyles.defaultAppBarTheme(), // 👈 using reusable appbar style
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
  ).copyWith(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
    surface: AppColors.surface,
    onPrimary: AppColors.white,
    onSecondary: AppColors.white,
    onBackground: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppDarkColors.primary,
  scaffoldBackgroundColor: AppDarkColors.background,
  appBarTheme: AppBarStyles.defaultAppBarTheme(
      isDarkMode: true), // 👈 using reusable appbar style for dark mode
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
  ).copyWith(
    primary: AppDarkColors.primary,
    secondary: AppDarkColors.secondary,
    background: AppDarkColors.background,
    surface: AppDarkColors.surface,
    onPrimary: AppDarkColors.textPrimary,
    onSecondary: AppDarkColors.textPrimary,
    onBackground: AppDarkColors.textPrimary,
    onSurface: AppDarkColors.textPrimary,
  ),
);
