// ----THIS IS NEW -----
import 'dart:developer' as devtools show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/constants/routes.dart';
import 'package:first_project/costume_widgets/text_field_widget.dart';
import 'package:first_project/services/auth/auth_exceptions.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/styles/app_bar_styles.dart';
import 'package:first_project/utiliies/sharedprefs.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../styles/button_styles.dart';
import '../styles/textfield_styles.dart';
import '../utiliies/show_error_dialog.dart';

// ======= LOGIN =========
class LoginViewState extends StatefulWidget {
  const LoginViewState({Key? key}) : super(key: key);

  @override
  State<LoginViewState> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginViewState> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool buttonHovered = false; // Added buttonHovered variable

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
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
                        await AuthService.firebase()
                            .logIn(email: email, password: password);
                        final user = AuthService.firebase().currentUser;
                        bool emailVerified = user?.isEmailVerified ?? false;
                        devtools.log(emailVerified.toString());
                        if (emailVerified) {
                          Navigator.of(context)
                              .pushReplacementNamed(notesRoute);
                        } else {
                          Navigator.of(context)
                              .pushReplacementNamed(verifyEmailRoute);
                        }
                      } on UserNotFoundAuthException {
                        await showErrorDialog(context, 'User not found');
                      } on WrongPasswordAuthException {
                        await showErrorDialog(context, 'Wrong credentials');
                      } on GenericAuthException {
                        await showErrorDialog(context, 'Authentication error');
                      }
                    },
                    style: ButtonStyles.saucyButtonStyle(buttonHovered),
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
                      child: const Text(
                        'LOGIN',
                      ),
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
