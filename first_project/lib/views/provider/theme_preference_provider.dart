import 'package:first_project/styles/themes/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferenceProvider with ChangeNotifier {
  late ThemeData _themeData;
  static const String _themeKey = 'theme_preference';

  ThemePreferenceProvider() {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    _themeData = (await _loadThemeFromPreferences()) ?? lightTheme;
    notifyListeners();
  }

  ThemeData get themeData => _themeData;

  // Load the theme from shared preferences
  Future<ThemeData?> _loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themePreference = prefs.getString(_themeKey);
    
    print('Loaded Theme Preference: $themePreference'); // Add this line to check the loaded theme preference
    
    // Return the corresponding ThemeData or null if not found
    return themePreference == 'dark' ? darkTheme : lightTheme;
  }


  // Save the selected theme to shared preferences
  void _saveThemeToPreferences(String themePreference) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themePreference);
  }

// Toggle the theme and save the preference
void toggleTheme() {
  _themeData = (_themeData == lightTheme) ? darkTheme : lightTheme;
  _saveThemeToPreferences(_themeData == lightTheme ? 'light' : 'dark');
  print('Current Theme: $_themeData'); // Add this line to check the current theme
  notifyListeners();
}

}
