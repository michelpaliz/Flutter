// lib/f-themes/themes/dark_theme.dart
import 'package:flutter/material.dart';
import 'package:hexora/f-themes/app_colors/palette/app_colors.dart';
import 'package:hexora/f-themes/app_colors/themes/text_styles/typography_extension.dart';
import 'package:hexora/f-themes/app_utilities/view-item-styles/app_bar/app_bar_styles.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppDarkColors.primary,
  scaffoldBackgroundColor: AppDarkColors.background,
  appBarTheme: AppBarStyles.defaultAppBarTheme(isDarkMode: true),
  colorScheme: ColorScheme.fromSwatch(
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
  extensions: <ThemeExtension<dynamic>>[
    AppTypography.dark(scale: 0.96), // defined below
  ],
);
