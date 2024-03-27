import 'package:first_project/models/user.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/services/auth/exceptions/password_exceptions.dart';
import 'package:first_project/services/auth/logic_backend/auth_service.dart';
import 'package:first_project/services/firestore_database/exceptions/firestore_exceptions.dart';
import 'package:first_project/services/firestore_database/logic_backend/firestore_service.dart';
import 'package:first_project/styles/themes/theme_data.dart';
import 'package:first_project/stateManangement/theme_preference_provider.dart';
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
  late FirestoreService _storeService;
  TextEditingController _currentPassword = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();

  // Variables to manage settings
  String userName = "";

  @override
  void initState() {
    super.initState();
    currentUser = _authService.costumeUser;
    // Load user-specific settings, if available
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

      // // Check if new password and confirmation password match
      // if (newPassword != confirmPassword) {
      //   // Display an error message when new password and confirmation password don't match
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(AppLocalizations.of(context)!.passwordNotMatch),
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      //   return false;
      // }

      // Call the changePassword method from your AuthService
      await _authService.changePassword(
          currentPassword, newPassword, confirmPassword);

      // Show a success message or any UI feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.passwordChangedSuccessfully),
          duration: Duration(seconds: 2),
        ),
      );

      return true;
    } on CurrentPasswordMismatchException {
      // Show an error message for incorrect current password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.currentPasswordIncorrect),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    } on PasswordMismatchException {
      // Show an error message for new password and confirmation mismatch
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordNotMatch),
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
          content: Text(AppLocalizations.of(context)!.errorChangingPassword),
          duration: Duration(seconds: 2),
        ),
      );

      return false;
    }
  }

  Future<String?> _changeUsername(String newUsername) async {
    try {
      // Check for invalid characters in the username
      if (!_isValidUsername(newUsername)) {
        return AppLocalizations.of(context)!.errorUnwantedCharactersUsername;
      }

      if (newUsername.length < 6 || newUsername.length > 10) {
        return AppLocalizations.of(context)!.errorUsernameLength;
      }

      // Assuming _storeService.changeUserName returns a Future<void>
      await _storeService.changeUsername(newUsername);

      // The username change was successful
      return null; // No error message
    } catch (error) {
      // Handle errors, log or rethrow the error as needed
      print("Error changing username: $error");

      // Check if the error is due to the username being already taken
      if (error is UsernameAlreadyTakenException) {
        return AppLocalizations.of(context)!.usernameAlreadyTaken;
      } else {
        return AppLocalizations.of(context)!.errorChangingUsername;
      }
    }
  }

  bool _isValidUsername(String username) {
    // Regular expression to check if the username contains only alphanumeric characters and underscores
    final RegExp regex = RegExp(r'^[a-zA-Z0-9_]+$');
    return regex.hasMatch(username);
  }

  Future<void> _onUsernameChangePressed() async {
    String? errorMessage = await _changeUsername(_userNameController.text);

    if (errorMessage != null) {
      // Display the error message to the user, e.g., using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    } else {
      // Username change was successful
      // Show a success message, e.g., using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.successChangingUsername),
          // You can customize the duration, appearance, and other properties of the SnackBar
        ),
      );

      // You may also perform additional actions or update the UI here
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.changePassword,
            style: TextStyle(fontFamily: 'lato', fontSize: 16),
          ),
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

  void _showChangeUsernameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.changeUsername,
            style: TextStyle(fontFamily: 'lato', fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _userNameController,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.userName,
                    hintStyle: TextStyle(fontSize: 12, fontFamily: 'lato')),
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
                _onUsernameChangePressed();
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
                onTap: () => _showChangeUsernameDialog(),
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.newPassword,
                  style: TextStyle(fontFamily: 'lato', fontSize: 16),
                ),
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
