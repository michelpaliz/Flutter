import 'package:flutter/material.dart';

class AppColors {
  // Background & surfaces
  static const Color background = Color(0xFFE3F2FD); // Blue50
  static const Color surface = Color(0xFFBBDEFB); // Blue100

  // Primary blue
  static const Color primary = Color(0xFF2196F3); // Blue500
  static const Color primaryLight = Color(0xFF64B5F6); // Blue300
  static const Color primaryDark = Color(0xFF1976D2); // Blue700

  // Secondary (accent) blue
  static const Color secondary = Color(0xFF03A9F4); // LightBlue500
  static const Color secondaryLight = Color(0xFF67DAFF); // LightBlue300
  static const Color secondaryDark = Color(0xFF007AC1); // LightBlue700

  // Text & icons
  static const Color textPrimary = Color(0xFF0D47A1); // Blue900
  static const Color textSecondary =
      Color(0xFF5472D3); // Blue700 with some opacity

  // Utility
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

class AppDarkColors {
  // Dark theme background & surfaces
  static const Color background = Color.fromARGB(255, 7, 35, 78); // Blue900
  static const Color surface = Color(0xFF1565C0); // Blue800

  // Primary blue stays bright against dark background
  static const Color primary = Color(0xFF2196F3); // Blue500
  static const Color primaryLight = Color(0xFF64B5F6); // Blue300
  static const Color primaryDark = Color(0xFF1976D2); // Blue700

  // Secondary accent
  static const Color secondary = Color(0xFF03A9F4); // LightBlue500
  static const Color secondaryLight = Color(0xFF67DAFF); // LightBlue300

  // Text & icons
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3E5FC); // LightBlue100

  // Error (leave red as-is for clarity on errors)
  static const Color error = Color(0xFFCF6679);
}
