import 'package:flutter/material.dart';

class AppBarStyles {
  static final ThemeData themeData = ThemeData(
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        fontFamily: 'bagel',
      ),
      backgroundColor: Color.fromARGB(178, 0, 131, 253),
      centerTitle: true,
    ),
    // Add more theme configurations here if needed
  );
}
