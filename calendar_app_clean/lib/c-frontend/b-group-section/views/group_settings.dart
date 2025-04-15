import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/b-backend/auth/auth_database/exceptions/password_exceptions.dart';
import 'package:first_project/d-stateManagement/theme_preference_provider.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late User? currentUser;
  late TextEditingController _currentPassword;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _userNameController;

  String userName = "";

  @override
  void initState() {
    super.initState();
    _currentPassword = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _userNameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    currentUser = authProvider.currentUser;
    if (currentUser != null) {
      setState(() {
        userName = currentUser!.userName;
      });
    }
  }

  Future<bool> _changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      if (newPassword.length < 6 || newPassword.length > 10) {
        _showSnackBar('Password must be between 6 and 10 characters.');
        return false;
      }

      final RegExp unwantedCharacters = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
      if (unwantedCharacters.hasMatch(newPassword)) {
        _showSnackBar('Password contains unwanted characters.');
        return false;
      }

      await authProvider.changePassword(
          currentPassword, newPassword, confirmPassword);

      _showSnackBar(AppLocalizations.of(context)!.passwordChangedSuccessfully);
      return true;
    } on CurrentPasswordMismatchException {
      _showSnackBar(AppLocalizations.of(context)!.currentPasswordIncorrect);
    } on PasswordMismatchException {
      _showSnackBar(AppLocalizations.of(context)!.passwordNotMatch);
    } on UserNotSignedInException {
      _showSnackBar('User is not signed in.');
    } catch (e) {
      print("Error changing password: $e");
      _showSnackBar(AppLocalizations.of(context)!.errorChangingPassword);
    }
    return false;
  }

  Future<String?> _changeUsername(String newUsername) async {
    try {
      if (!_isValidUsername(newUsername)) {
        return AppLocalizations.of(context)!.errorUnwantedCharactersUsername;
      }
      if (newUsername.length < 6 || newUsername.length > 10) {
        return AppLocalizations.of(context)!.errorUsernameLength;
      }

      // Simulate or integrate with your backend here
      // await authProvider.changeUsername(newUsername);
      // Update UI
      setState(() => userName = newUsername);
      return null;
    } catch (error) {
      print("Error changing username: $error");
      return AppLocalizations.of(context)!.errorChangingUsername;
    }
  }

  bool _isValidUsername(String username) {
    final RegExp regex = RegExp(r'^[a-zA-Z0-9_]+$');
    return regex.hasMatch(username);
  }

  void _onUsernameChangePressed() async {
    final errorMessage = await _changeUsername(_userNameController.text);
    if (errorMessage != null) {
      _showSnackBar(errorMessage);
    } else {
      _showSnackBar(AppLocalizations.of(context)!.successChangingUsername);
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              _changePassword(
                _currentPassword.text,
                _newPasswordController.text,
                _confirmPasswordController.text,
              );
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showChangeUsernameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.changeUsername,
          style: TextStyle(fontFamily: 'lato', fontSize: 16),
        ),
        content: TextField(
          controller: _userNameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.userName,
            hintStyle: TextStyle(fontSize: 12, fontFamily: 'lato'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              _onUsernameChangePressed();
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context)!.userName),
                subtitle: Text(userName),
                onTap: _showChangeUsernameDialog,
              ),
              ListTile(
                title: Text(
                  AppLocalizations.of(context)!.newPassword,
                  style: TextStyle(fontFamily: 'lato', fontSize: 16),
                ),
                onTap: _showChangePasswordDialog,
              ),
              // ListTile(
              //   title: Text(AppLocalizations.of(context)!.darkMode),
              //   trailing: Switch(
              //     value: themeProvider.themeData == darkTheme,
              //     onChanged: (_) => themeProvider.toggleTheme(),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
