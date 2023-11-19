import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:first_project/provider/theme_preference_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class Settings extends StatefulWidget {
  const Settings({Key? key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late AuthService _authService = AuthService.firebase();
  late User? currentUser;
  late ThemePreferenceProvider _themePreferenceProvider;

  // Variables to manage settings
  String userName = "";

  @override
  void initState() {
    super.initState();
    currentUser = _authService.costumeUser;
    // Load user-specific settings, if available
    _themePreferenceProvider =
        Provider.of<ThemePreferenceProvider>(context, listen: false);
    loadUserSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize ThemePreferenceProvider
    _themePreferenceProvider =
        Provider.of<ThemePreferenceProvider>(context, listen: false);

    // Load user-specific settings, if available
    loadUserSettings();
  }

  // Load user-specific settings
  void loadUserSettings() {
    // You can fetch settings data for the user from a database or other storage
    // Here, we set some sample values for demonstration purposes
    setState(() {
      userName = "User Name"; // Load the user's name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemePreferenceProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.settings),
          ),
          body: ListView(
            children: <Widget>[
              ListTile(
                title: Text(AppLocalizations.of(context)!.userName),
                subtitle: Text(userName),
                onTap: () {
                  // Implement a dialog or form to allow the user to change their name
                  // Update the 'userName' variable when the user makes changes
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.newPassword),
                onTap: () {
                  // Implement a dialog or form to allow the user to change their password
                  // Update the 'newPassword' and 'confirmPassword' variables when the user makes changes
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.darkMode),
                trailing: Switch(
                  value: themeProvider.themeData == darkTheme,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

