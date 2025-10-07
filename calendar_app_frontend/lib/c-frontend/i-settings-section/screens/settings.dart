import 'package:flutter/material.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/auth_provider.dart';
import 'package:hexora/b-backend/login_user/auth/exceptions/password_exceptions.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/widgets/section_header.dart';
import 'package:hexora/c-frontend/i-settings-section/dialogs/change_password_dialog.dart';
import 'package:hexora/c-frontend/i-settings-section/dialogs/change_username_dialog.dart';
import 'package:hexora/c-frontend/i-settings-section/sections/account_section.dart';
import 'package:hexora/c-frontend/i-settings-section/sections/preferences_section.dart';
import 'package:hexora/c-frontend/i-settings-section/sheets/language_sheet.dart';
import 'package:hexora/c-frontend/i-settings-section/widgets/section_card.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/d-local-stateManagement/local/LocaleProvider.dart';
import 'package:hexora/d-local-stateManagement/theme/theme_preference_provider.dart';
import 'package:hexora/f-themes/palette/app_colors.dart';
import 'package:hexora/f-themes/themes/define_colors/theme_data.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late User? currentUser;
  String userName = "";
  static const String _appVersion = '1.0.0';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    currentUser = authProvider.currentUser;
    if (currentUser != null) {
      userName = currentUser!.userName;
    }
  }

  // ===== Actions =====

  Future<bool> _changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      if (newPassword.length < 6 || newPassword.length > 10) {
        _snack(loc.errorUsernameLength);
        return false;
      }
      final unwanted = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
      if (unwanted.hasMatch(newPassword)) {
        _snack(loc.errorUnwantedCharactersUsername);
        return false;
      }

      await authProvider.changePassword(
        currentPassword,
        newPassword,
        confirmPassword,
      );

      _snack(loc.passwordChangedSuccessfully);
      return true;
    } on CurrentPasswordMismatchException {
      _snack(loc.currentPasswordIncorrect);
    } on PasswordMismatchException {
      _snack(loc.passwordNotMatch);
    } on UserNotSignedInException {
      _snack(loc.userNotSignedIn);
    } catch (_) {
      _snack(loc.errorChangingPassword);
    }
    return false;
  }

  Future<String?> _changeUsername(String newUsername) async {
    final loc = AppLocalizations.of(context)!;
    try {
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(newUsername)) {
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

  void _confirmLogout() {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.logoutConfirmTitle),
        content: Text(l.logoutConfirmMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _logout();
            },
            child: Text(l.logout),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    try {
      await auth.logOut(); // or logout()
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.loginRoute,
      (_) => false,
    );
  }

  void _openLanguageSheet() => showLanguageSheet(context);

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // ===== UI =====

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppDarkColors.background : AppColors.background;

    return Consumer<ThemePreferenceProvider>(
      builder: (_, themeProv, __) => Scaffold(
        appBar: AppBar(title: Text(loc.settings)),
        backgroundColor: bg,
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            SectionHeader(title: loc.accountSectionTitle),
            SectionCard(
              child: AccountSection(
                userName: userName,
                onEditUsername: () async {
                  final newName = await showChangeUsernameDialog(context);
                  if (newName == null) return;
                  final err = await _changeUsername(newName);
                  _snack(err ??
                      AppLocalizations.of(context)!.successChangingUsername);
                },
                onChangePassword: () async {
                  final result = await showChangePasswordDialog(context);
                  if (result == null) return;
                  await _changePassword(
                      result.current, result.newPass, result.confirm);
                },
                onLogout: _confirmLogout,
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(title: loc.preferencesSectionTitle),
            SectionCard(
              child: PreferencesSection(
                isDark: themeProv.themeData == darkTheme,
                onToggleDark: () => themeProv.toggleTheme(),
                languageName: _languageName(context),
                onChangeLanguage: _openLanguageSheet,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '${loc.appVersionLabel}: $_appVersion',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  String _languageName(BuildContext context) {
    final lp = Provider.of<LocaleProvider>(context, listen: false);
    return lp.locale.languageCode == 'es' ? 'Español' : 'English';
  }
}
