import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/app_bar/app_bar_styles.dart';
import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.green,
  scaffoldBackgroundColor: AppColors.yellow,
  appBarTheme:
      AppBarStyles.defaultAppBarTheme(), // 👈 using reusable appbar style
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.light,
    primarySwatch: Colors.green,
  ).copyWith(
    secondary: AppColors.blue,
    background: AppColors.yellow,
    primary: AppColors.green,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.green,
  scaffoldBackgroundColor: AppColors.brown,
  appBarTheme: AppBarStyles.defaultAppBarTheme(
      isDarkMode: true), // 👈 using reusable appbar style for dark mode
  colorScheme: ColorScheme.fromSwatch(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
  ).copyWith(
    secondary: AppColors.blue,
    background: AppColors.brown,
    primary: AppColors.green,
  ),
);
