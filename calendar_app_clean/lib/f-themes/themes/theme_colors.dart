import 'package:flutter/material.dart';

class ThemeColors {
  // Existing functions
  static Color getTextColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  static Color getCardBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color.fromARGB(255, 104, 140, 171)
        : const Color.fromARGB(196, 178, 219, 228);
  }

  static Color getContainerBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color.fromARGB(255, 31, 65, 95)
        : const Color.fromARGB(196, 178, 219, 228);
  }

  // 🚀 NEW: Button Text Color
  static Color getButtonTextColor(BuildContext context) {
    return getTextColor(context); // same as normal text
  }

  // 🚀 NEW: Button Background Color
  static Color getButtonBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark
        ? const Color.fromARGB(255, 70, 90, 120) // dark mode button color
        : const Color.fromARGB(255, 200, 230, 255); // light mode button color
  }
}
