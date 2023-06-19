// ======= REGISTER =========

import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:flutter/material.dart';

import '../constants/routes.dart';
import '../services/auth/auth_exceptions.dart';
import '../styles/button_styles.dart';
import '../styles/textfield_styles.dart';
import '../utiliies/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool buttonHovered = false; // Added buttonHovered variable
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();

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
    return Scaffold(
      appBar: AppBar(
        title: Text("SCHEDULE"),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          fontFamily: 'bagel',
        ),
        backgroundColor: Color.fromARGB(178, 0, 131, 253),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 5.0),
          child: Column(
            children: [
              Image.asset(
                'assets/images/login_image.png', // Replace with your image path
                width: 200,
                height: 150,
              ),
              Text(
                'REGISTER HERE',
                style: TextStyle(
                  fontSize: 37,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(202, 34, 108, 192),
                  fontFamily: 'bagel',
                ),
              ),
              ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: 'Enter your name',
                      labelText: 'Name',
                      suffixIcon: Icons.person,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ageController,
                    decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: 'yyyy-mm-dd',
                      labelText: 'Age',
                      suffixIcon: Icons.calendar_today,
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: 'Introduce your email',
                      labelText: 'Email',
                      suffixIcon: Icons.email,
                    ),
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    decoration: TextFieldStyles.saucyInputDecoration(
                      hintText: 'Introduce your password',
                      labelText: 'Password',
                      suffixIcon: Icons.lock,
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  //TODO use these variables below to create an user object
                  final name = _nameController.text;
                  final age = _ageController.text;
                  try {
                    // The await keyword is used to wait for the registration process to complete before proceeding.
                    await AuthService.firebase()
                        .createUser(email: email, password: password);
                    AuthService.firebase().sendEmailVerification;
                    //We're not gonna replace the registration page we only push.
                    Navigator.of(context).pushNamed(verifyEmailRoute);
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
              TextButton(
                onPressed: () async {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
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
      // backgroundColor: const Color.fromARGB(255, 180, 189, 197),
    );
  }
}
