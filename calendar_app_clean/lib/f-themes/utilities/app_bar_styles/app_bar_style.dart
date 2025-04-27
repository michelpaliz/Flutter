import 'package:first_project/f-themes/palette/app_colors.dart'; // import your palette
import 'package:flutter/material.dart';

class AppBarStyles {
  static AppBarTheme defaultAppBarTheme({bool isDarkMode = false}) {
    return AppBarTheme(
      color: isDarkMode ? AppColors.greenDark : AppColors.brown,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'YourCustomFont', // you can customize here
      ),
      iconTheme: IconThemeData(
        color: Colors.white, // For back button and icons inside AppBar
      ),
    );
  }
}
