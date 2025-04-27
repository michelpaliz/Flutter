import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/b-backend/auth/auth_database/exceptions/auth_exceptions.dart';
import 'package:first_project/c-frontend/d-log-user-section/login/login_init.dart';
import 'package:first_project/c-frontend/routes/appRoutes.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/f-themes/palette/color_properties.dart';
import 'package:first_project/f-themes/utilities/logo/logo_widget.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/text_field/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../f-themes/utilities/view-item-styles/text_field/textfield_styles.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final AuthProvider _authProvider;
  late final UserManagement _userManagement;
  late final GroupManagement _groupManagement;
  late LoginInitializer _loginInitializer;

  bool buttonHovered = false;
  late ButtonStyle _myCustomButtonStyle;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _myCustomButtonStyle = ColorProperties.defaultButton();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement =
        Provider.of<GroupManagement>(context, listen: false); // 👈
    _loginInitializer = LoginInitializer(
      authProvider: _authProvider,
      userManagement: _userManagement,
      groupManagement: _groupManagement,
    );
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.login),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LogoWidget.buildLogoAvatar(size: LogoSize.large),
            const SizedBox(height: 30),
            TextFieldWidget(
              controller: _email,
              decoration: TextFieldStyles.saucyInputDecoration(
                hintText: AppLocalizations.of(context)!.emailHint,
                labelText: 'Email',
                suffixIcon: Icons.email,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              controller: _password,
              decoration: TextFieldStyles.saucyInputDecoration(
                hintText: AppLocalizations.of(context)!.passwordHint,
                labelText: AppLocalizations.of(context)!.password,
                suffixIcon: Icons.lock,
              ),
              keyboardType: TextInputType.text,
              obscureText: true,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                debugPrint("🔘 Login button pressed");
                final email = _email.text.trim();
                final password = _password.text.trim();
                try {
                  await _loginInitializer.initializeUserAndServices(
                      email, password);

                  // ✅ No need to manually set userManagement anymore
                  Navigator.pushNamed(context, AppRoutes.homePage);
                } on UserNotFoundAuthException {
                  _showSnackBar(AppLocalizations.of(context)!.userNotFound);
                } on WrongPasswordAuthException {
                  _showSnackBar(AppLocalizations.of(context)!.wrongCredentials);
                } on GenericAuthException {
                  _showSnackBar(AppLocalizations.of(context)!.authError);
                } catch (e) {
                  _showSnackBar('Login failed: $e');
                }
              },
              style: _myCustomButtonStyle,
              child: Text(AppLocalizations.of(context)!.login),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.passwordRecoveryRoute);
              },
              child: Text(AppLocalizations.of(context)!.forgotPassword),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.registerRoute);
              },
              child: Text(AppLocalizations.of(context)!.notRegistered),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
