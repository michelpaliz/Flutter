import 'package:first_project/models/user.dart';
import 'package:first_project/provider/provider_management.dart';
import 'package:first_project/services/auth/exceptions/password_exceptions.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore_database/implements/firestore_service.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:first_project/provider/theme_preference_provider.dart';
import 'package:flutter/material.dart';
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
  late FirestoreService _storeService;
  TextEditingController _currentPassword = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

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

    // Access the inherited widget in the didChangeDependencies method.
    final providerManagement = Provider.of<ProviderManagement>(context);

    // Initialize the _storeService using the providerManagement.
    _storeService = FirestoreService.firebase(providerManagement);
  }

  // Load user-specific settings
  void loadUserSettings() {
    // You can fetch settings data for the user from a database or other storage
    // Here, we set some sample values for demonstration purposes
    setState(() {
      userName = currentUser!.userName; // Load the user's name
    });
  }

  /**
 * Changes the user's password.
 *
 * @param currentPassword The user's current password for reauthenticate.
 * @param newPassword The new password to set for the user.
 * @param confirmPassword Confirmation of the new password for validation.
 * @return True if the password change is successful, false otherwise.
 */
  Future<bool> _changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      // Check password length
      if (newPassword.length < 6 || newPassword.length > 10) {
        // Display an error message for invalid password length
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password must be between 6 and 10 characters.'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }

      // Check unwanted characters (customize the pattern based on your requirements)
      final RegExp unwantedCharacters = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
      if (unwantedCharacters.hasMatch(newPassword)) {
        // Display an error message for unwanted characters
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password contains unwanted characters.'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }

      // Check if new password and confirmation password match
      if (newPassword != confirmPassword) {
        // Display an error message when new password and confirmation password don't match
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('New password and confirmation password do not match.'),
            duration: Duration(seconds: 2),
          ),
        );
        return false;
      }

      // Call the changePassword method from your AuthService
      await _authService.changePassword(
          currentPassword, newPassword, confirmPassword);

      // Show a success message or any UI feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password changed successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      return true;
    } on CurrentPasswordMismatchException {
      // Show an error message for incorrect current password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Current password is incorrect. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    } on PasswordMismatchException {
      // Show an error message for new password and confirmation mismatch
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('New password and confirmation password do not match.'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    } on UserNotSignedInException {
      // Show an error message for user not being signed in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User is not signed in.'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    } catch (error) {
      // Handle other errors during password change
      print("Error changing password: $error");

      // Show a generic error message or any UI feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change password. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );

      return false;
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.changePassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPassword,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.currentPassword,
                ),
                obscureText: true,
              ),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.newPassword,
                ),
                obscureText: true,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.confirmPassword,
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                // Perform password change logic here
                _changePassword(
                  // Pass the current password from your authentication service
                  _currentPassword.text,
                  _newPasswordController.text,
                  _confirmPasswordController.text,
                );
                Navigator.pop(context); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
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
                  _showChangePasswordDialog();
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
