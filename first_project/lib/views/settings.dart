
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late AuthService _authService = AuthService.firebase();
  late User? currentUser;

  // Variables to manage settings
  String userName = "";
  String newPassword = "";
  String confirmPassword = "";
  bool isDarkModeEnabled = false;
  bool isSpanishSelected = false;

  @override
  void initState() {
    super.initState();
    currentUser = _authService.costumeUser;
    
    // Load user-specific settings, if available
    loadUserSettings();
  }

  // Load user-specific settings
  void loadUserSettings() {
    // You can fetch settings data for the user from a database or other storage
    // Here, we set some sample values for demonstration purposes
    setState(() {
      userName = "User Name"; // Load the user's name
      isDarkModeEnabled = false; // Load user's dark mode preference
      isSpanishSelected = false; // Load user's language preference
    });
  }

  // Save user-specific settings
  void saveUserSettings() {
    // You can save user settings to a database or other storage
    // Here, we're just updating the local state for demonstration purposes
    setState(() {
      userName = userName; // Update user's name
      isDarkModeEnabled = isDarkModeEnabled; // Update user's dark mode preference
      isSpanishSelected = isSpanishSelected; // Update user's language preference
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("User Name"),
            subtitle: Text(userName),
            onTap: () {
              // Implement a dialog or form to allow the user to change their name
              // Update the 'userName' variable when the user makes changes
            },
          ),
          ListTile(
            title: Text("Change Password"),
            onTap: () {
              // Implement a dialog or form to allow the user to change their password
              // Update the 'newPassword' and 'confirmPassword' variables when the user makes changes
            },
          ),
          ListTile(
            title: Text("Dark Mode"),
            trailing: Switch(
              value: isDarkModeEnabled,
              onChanged: (value) {
                setState(() {
                  isDarkModeEnabled = value;
                  // Implement code to toggle dark mode in your app
                });
              },
            ),
          ),
          ListTile(
            title: Text("Language"),
            subtitle: Text(isSpanishSelected ? "Spanish" : "English"),
            onTap: () {
              // Implement a dialog or form to allow the user to change the language
              // Update the 'isSpanishSelected' variable when the user makes changes
            },
          ),
        ],
      ),
    );
  }
}
