import 'package:flutter/material.dart';

class AppBarStyles {
  static final ThemeData themeData = ThemeData(
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        fontFamily: 'Lato',
      ),
      backgroundColor: Color.fromARGB(255, 60, 185, 238),
      centerTitle: true,
    ),
    // Add more theme configurations here if needed
  );
}
