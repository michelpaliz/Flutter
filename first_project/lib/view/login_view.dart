// ----THIS IS NEW -----
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ======= LOGIN =========
class LoginViewState extends StatefulWidget {
  const LoginViewState({Key? key}) : super(key: key);

  @override
  State<LoginViewState> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginViewState> {
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
        title: const Text('Login'),
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
              // FirebaseAuth.instance.signInWithEmailAndPassword(
              //     email: email, password: password);
              //Handling user not found
              try {
                final userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: email, password: password);
              } on FirebaseAuthException catch (user) {
                if (user.code == 'user-not-found') {
                  print('User not found');
                } else if (user.code == 'wrong-password') {
                  print('Wrong password');
                }
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/register/", (route) => false);
              },
              child: const Text('Not registered yet ? Register here.')),
        ],
      ),
      backgroundColor: const Color.fromARGB(
          255, 180, 189, 197), // Set the background color for the Register page
    );
  }
}
