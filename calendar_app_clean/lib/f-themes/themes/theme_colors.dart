import 'package:flutter/material.dart';

class ThemeColors {
  // Constant for text color based on the theme
  static Color getTextColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  static Color getCardBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? Color.fromARGB(255, 104, 140, 171) : Color.fromARGB(196, 178, 219, 228);
  }

  static Color getContainerBackgroundColor(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return theme.brightness == Brightness.dark ? Color.fromARGB(255, 31, 65, 95) : Color.fromARGB(196, 178, 219, 228);
  }
}
