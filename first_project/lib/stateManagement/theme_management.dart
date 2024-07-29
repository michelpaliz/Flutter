import 'package:first_project/styles/themes/theme_data.dart';
import 'package:flutter/material.dart';

class ThemeManagement extends ChangeNotifier {
  ThemeData _themeData = lightTheme;

  ThemeData get themeData => _themeData;

  void toggleTheme() {
    _themeData = (_themeData == lightTheme) ? darkTheme : lightTheme;
    notifyListeners();
  }
}
