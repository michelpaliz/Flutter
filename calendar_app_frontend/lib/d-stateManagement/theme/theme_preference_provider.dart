import 'package:calendar_app_frontend/f-themes/themes/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferenceProvider with ChangeNotifier {
  ThemeData _themeData = lightTheme; // Set an initial default value
  static const String _themeKey = 'theme_preference';

  ThemePreferenceProvider() {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    _themeData = (await _loadThemeFromPreferences()) ?? lightTheme;
    notifyListeners();
  }

  ThemeData get themeData => _themeData;

  Future<ThemeData?> _loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themePreference = prefs.getString(_themeKey);

    print('Loaded Theme Preference: $themePreference');

    return themePreference == 'dark' ? darkTheme : lightTheme;
  }

  void _saveThemeToPreferences(String themePreference) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themePreference);
  }

  void toggleTheme() {
    _themeData = (_themeData == lightTheme) ? darkTheme : lightTheme;
    _saveThemeToPreferences(_themeData == lightTheme ? 'light' : 'dark');
    print('Current Theme: $_themeData');
    notifyListeners();
  }
}
