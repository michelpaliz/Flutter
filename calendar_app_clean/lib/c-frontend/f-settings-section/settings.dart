import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/b-backend/auth/auth_database/exceptions/password_exceptions.dart';
import 'package:first_project/d-stateManagement/LocaleProvider.dart';
import 'package:first_project/d-stateManagement/theme_preference_provider.dart';
import 'package:first_project/f-themes/themes/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

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
      userName = currentUser!.userName;
    }
  }

  Future<bool> _changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    final loc = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (newPassword.length < 6 || newPassword.length > 10) {
        _showSnackBar(loc.errorUsernameLength);
        return false;
      }

      final unwanted = RegExp(r'[!@#\\$%^&*(),.?":{}|<>]');
      if (unwanted.hasMatch(newPassword)) {
        _showSnackBar(loc.errorUnwantedCharactersUsername);
        return false;
      }

      await authProvider.changePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      _showSnackBar(loc.passwordChangedSuccessfully);
      return true;
    } on CurrentPasswordMismatchException {
      _showSnackBar(loc.currentPasswordIncorrect);
    } on PasswordMismatchException {
      _showSnackBar(loc.passwordNotMatch);
    } on UserNotSignedInException {
      _showSnackBar(loc.userNotSignedIn);
    } catch (_) {
      _showSnackBar(loc.errorChangingPassword);
    }
    return false;
  }

  Future<String?> _changeUsername(String newUsername) async {
    final loc = AppLocalizations.of(context)!;
    try {
      if (!_isValidUsername(newUsername)) {
        return loc.errorUnwantedCharactersUsername;
      }
      if (newUsername.length < 6 || newUsername.length > 10) {
        return loc.errorUsernameLength;
      }
      setState(() => userName = newUsername);
      return null;
    } catch (_) {
      return loc.errorChangingUsername;
    }
  }

  bool _isValidUsername(String username) =>
      RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username);

  void _onUsernameChangePressed() async {
    final error = await _changeUsername(_userNameController.text);
    _showSnackBar(
        error ?? AppLocalizations.of(context)!.successChangingUsername);
  }

  void _showChangePasswordDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.changePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _currentPassword,
              decoration: InputDecoration(labelText: loc.currentPassword),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: loc.newPassword),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: loc.confirmPassword),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
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
            child: Text(loc.save),
          ),
        ],
      ),
    );
  }

  void _showChangeUsernameDialog() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.changeUsername),
        content: TextField(
          controller: _userNameController,
          decoration: InputDecoration(labelText: loc.userName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () {
              _onUsernameChangePressed();
              Navigator.pop(context);
            },
            child: Text(loc.save),
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
    final loc = AppLocalizations.of(context)!;
    final localeProv = Provider.of<LocaleProvider>(context, listen: false);

    return Consumer<ThemePreferenceProvider>(
      builder: (_, themeProv, __) => Scaffold(
        appBar: AppBar(title: Text(loc.settings)),
        body: ListView(
          children: [
            ListTile(
              title: Text(loc.userName),
              subtitle: Text(userName),
              onTap: _showChangeUsernameDialog,
            ),
            ListTile(
              title: Text(loc.newPassword),
              onTap: _showChangePasswordDialog,
            ),
            ListTile(
              title: Text(loc.darkMode),
              trailing: Switch(
                value: themeProv.themeData == darkTheme,
                onChanged: (_) => themeProv.toggleTheme(),
              ),
            ),
            // Language selector
            ListTile(
              title: Text(loc.language),
              trailing: DropdownButton<Locale>(
                value: localeProv.locale,
                icon: const Icon(Icons.language),
                items: AppLocalizations.supportedLocales.map((locale) {
                  final name =
                      locale.languageCode == 'es' ? 'Español' : 'English';
                  return DropdownMenuItem(
                    value: locale,
                    child: Text(name),
                  );
                }).toList(),
                onChanged: (newLoc) {
                  if (newLoc != null) localeProv.setLocale(newLoc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
