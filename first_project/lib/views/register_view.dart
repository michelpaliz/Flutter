// ======= REGISTER =========
import 'package:first_project/services/firestore/implements/store_service.dart';
import 'package:first_project/styles/app_bar_styles.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../costume_widgets/text_field_widget.dart';
import '../models/user.dart';
import '../services/auth/auth_exceptions.dart';
import '../services/auth/implements/auth_service.dart';
import '../styles/button_styles.dart';
import '../styles/textfield_styles.dart';
import '../utiliies/show_error_dialog.dart';

import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  bool buttonHovered = false; // Added buttonHovered variable
  late final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
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
                  'assets/images/login_image.png', // Replace with your image path
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'REGISTER',
                    style: TextStyle(
                      fontSize: 37,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(202, 34, 108, 192),
                      fontFamily: 'rigtheous',
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextFieldWidget(
                    controller: _nameController,
                    decoration: TextFieldStyles.saucyInputDecoration(
                        hintText: 'Enter your name',
                        labelText: 'Name',
                        suffixIcon: Icons.person),
                    keyboardType: TextInputType.text),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
                TextFieldWidget(
                  controller: _confirmPassword,
                  decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: 'Introduce again password',
                      labelText: 'Confirm password',
                      suffixIcon: Icons.lock),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                ),
                const SizedBox(height: 10),
                Container(
                  width: 0,
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      final name = _nameController.text;
                      final confirmPassword = _confirmPassword.text;
                      String? registrationStatus;

                      if (password != confirmPassword) {
                        await showErrorDialog(
                            context, 'Passwords do not match');
                        return;
                      }
                      try {
                        // The await keyword is used to wait for the registration process to complete before proceeding.
                        await AuthService.firebase()
                            .createUser(email: email, password: password);

                        // Sign in the user after successful registration
                        await AuthService.firebase()
                            .logIn(email: email, password: password);

                        // Add the user to the database
                        User person = User(name, email, null);
                        registrationStatus = await StoreService.firebase()
                            .uploadPersonToFirestore(person: person);

                        //We're gonna replace the previous state with the new one
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            verifyEmailRoute, (route) => false);
                      } on WeakPasswordException {
                        await showErrorDialog(context, 'weak password');
                      } on EmailAlreadyUseAuthException {
                        await showErrorDialog(context, 'Email already in use');
                      } on InvalidEmailAuthException {
                        await showErrorDialog(
                            context, 'This is an invalid email address');
                      } on GenericAuthException {
                        await showErrorDialog(context, 'Registration error');
                      }
                      ;
                      if (registrationStatus != null) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Registration Status'),
                                content: registrationStatus != null
                                    ? Text(registrationStatus)
                                    : const Text('Registration failed'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              );
                            });
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
                        'Register',
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pushNamed(context, loginRoute);
                  },
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
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: 'Already registered? ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              )),
                          TextSpan(
                            text: 'Login here.',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              // decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    // backgroundColor: const Color.fromARGB(255, 180, 189, 197),
  }
}
