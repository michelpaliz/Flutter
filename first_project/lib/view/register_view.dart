// ======= REGISTER =========

import 'package:flutter/material.dart';

import '../styles/button_styles.dart';
import '../styles/textfield_styles.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
  return Scaffold(
    appBar: AppBar(
      title: const Text('Register'),
      backgroundColor: const Color.fromARGB(113, 21, 109, 190),
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
      child: Column(
        children: [
          Image.asset(
            'assets/images/register_image.png', // Replace with your image path
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
          TextButton(
            onPressed: () async {
              // Registration button logic
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
          // Login button
          TextButton(
            onPressed: () {
              // Login button logic
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
                'Already registered? Login here.',
              ),
            ),
          ),
        ],
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 180, 189, 197),
  );
}

}
