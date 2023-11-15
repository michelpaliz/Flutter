// ----THIS IS NEW -----
import 'dart:developer' as devtools show log;

import 'package:first_project/enums/color_properties.dart';
import 'package:first_project/enums/routes/routes.dart';
import 'package:first_project/main.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/auth_exceptions.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/styles/view-item-styles/app_bar_styles.dart';
import 'package:first_project/styles/view-item-styles/text_field_widget.dart';
import 'package:first_project/views/log-user/login_init.dart';
import 'package:first_project/views/log-user/main_init.dart';
import 'package:first_project/views/my_app.dart';
import 'package:first_project/provider/provider_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../styles/costume_widgets/show_error_dialog.dart';
import '../../styles/view-item-styles/textfield_styles.dart';

// ======= LOGIN =========
class LoginView extends StatefulWidget {
  final Function(User) onLoginSuccess;

  const LoginView({Key? key, required this.onLoginSuccess}) : super(key: key);

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
    _loginInitializer = LoginInitializer(
        authService: _authService,
        storeService: StoreService.firebase(ProviderManagement(user: null)));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppBarStyles.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text("SCHEDULE"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              children: [
                Image.asset(
                  'assets/images/beach_image.png', // Replace with your image path
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 37,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(202, 34, 108, 192),
                      fontFamily: 'rigtheous',
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                TextFieldWidget(
                  controller: _email,
                  decoration: TextFieldStyles.saucyInputDecoration(
                    hintText: 'Introduce your email',
                    labelText: 'Email',
                    suffixIcon: Icons.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  controller: _password,
                  decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: 'Introduce your password',
                      labelText: 'Password',
                      suffixIcon: Icons.lock),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                Container(
                  width: 0,
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;

                      try {
                        await _loginInitializer.initializeUserAndServices(
                            email, password);

                        User? userFetched = _loginInitializer.getUser;

                        if (userFetched == null) {
                          throw UserNotFoundAuthException();
                        }
                        devtools.log(
                            'This is the user fetched from the login $userFetched');
                        widget.onLoginSuccess(userFetched);
                        print('Login successful. Navigating to main screen...');
                        await AppInitializer.goToMain(context, userFetched);
                        print('Navigation to main screen completed.');

                      } on UserNotFoundAuthException {
                        await showErrorDialog(context, 'User not found');
                      } on WrongPasswordAuthException {
                        await showErrorDialog(context, 'Wrong credentials');
                      } on GenericAuthException {
                        await showErrorDialog(context, 'Authentication error');
                      }
                    },
                    style: _myCustomButtonStyle,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) {
                        setState(() {
                          buttonHovered = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          buttonHovered = false;
                        });
                      },
                      child: const Text('LOGIN',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, registerRoute);
                    },
                    child: const Text('Not registered yet ? Register here.')),
              ],
            ),
          ),
        ),
        // backgroundColor: const Color.fromARGB(255, 180, 189,
        //     197), // Set the background color for the Register page
      ),
    );
  }
}
