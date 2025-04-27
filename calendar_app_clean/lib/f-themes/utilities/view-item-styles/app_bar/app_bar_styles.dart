import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:flutter/material.dart';

class AppBarStyles {
  static AppBarTheme defaultAppBarTheme({bool isDarkMode = false}) {
    return AppBarTheme(
      color: isDarkMode ? AppColors.greenDark : AppColors.brown,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontFamily: 'Lato', // Or any font you want
      ),
      iconTheme: const IconThemeData(
        color: Colors.white, // Make back arrow and other icons white
      ),
      foregroundColor: Colors.white, // 👈 THIS IS THE FINAL MISSING PIECE
    );
  }
}
