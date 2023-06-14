// ======= REGISTER =========

import 'dart:developer' as devtools show log;
import 'package:first_project/constants/routes.dart';
import 'package:first_project/services/auth/auth_exceptions.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/utiliies/show_error_dialog.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
        title: const Text('Register'),
        backgroundColor: const Color.fromARGB(113, 21, 109, 190),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              hintText: 'Enter your email here',
            ),
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(hintText: 'Enter your password'),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                // The await keyword is used to wait for the registration process to complete before proceeding.
                AuthService.firebase()
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
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Already registered ? Login here.')),
        ],
      ),
      backgroundColor: const Color.fromARGB(
          255, 180, 189, 197), // Set the background color for the Register page
    );
  }
}
