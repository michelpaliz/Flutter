// ----THIS IS NEW -----
import 'package:first_project/enums/color_properties.dart';
import 'package:first_project/enums/routes/appRoutes.dart';
import 'package:first_project/a-models/model/user_data/user.dart';
import 'package:first_project/b-backend/database_conection/auth_database/exceptions/auth_exceptions.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/styles/widgets/view-item-styles/text_field_widget.dart';
import 'package:first_project/c-frontend/c-log-user-section/login_init.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:provider/provider.dart';

import '../../b-backend/database_conection/auth_database/logic_backend/auth_service.dart';
import '../../styles/widgets/view-item-styles/textfield_styles.dart';

// ======= LOGIN =========
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool buttonHovered = false; // Added buttonHovered variable
  late ButtonStyle _myCustomButtonStyle;
  late final AuthService _authService;
  late LoginInitializer _loginInitializer;

  @override
  void initState() {
    super.initState();
    _authService = AuthService.firebase();
    _email = TextEditingController();
    _password = TextEditingController();
    _myCustomButtonStyle = ColorProperties.defaultButton();
    _loginInitializer = LoginInitializer(authService: _authService);
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
        title: Text("SCHEDULE"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/beach_image.png', // Replace with your image path
              width: 100,
              height: 100,
            ),
            Text(
              AppLocalizations.of(context)!.login,
              style: TextStyle(
                fontSize: 37,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(202, 34, 108, 192),
                fontFamily: 'rigtheous',
              ),
            ),
            SizedBox(height: 30),
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
                  suffixIcon: Icons.lock),
              keyboardType: TextInputType.text,
              obscureText: true,
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await _loginInitializer.initializeUserAndServices(
                      email, password);

                  User? userFetched = _loginInitializer.getUser;
                  // Update the user in the provider
                  final userManagement =
                      Provider.of<UserManagement>(context, listen: false);
                  userManagement.setCurrentUser(userFetched!);
                  Navigator.pushNamed(context, AppRoutes.homePage);
                } on UserNotFoundAuthException {
                  // Handle user not found exception
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.userNotFound),
                  ));
                } on WrongPasswordAuthException {
                  // Handle wrong password exception
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.wrongCredentials),
                  ));
                } on GenericAuthException {
                  // Handle generic authentication exception
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.authError),
                  ));
                }
              },
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
}
