import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/view/login_view.dart';
import 'package:first_project/view/register_view.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
    routes:{
      "/login/": (context) => const LoginViewState(),
      "/register/": (context) => const RegisterView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              // final currentUser = FirebaseAuth.instance.currentUser;
              // final emailVerified = currentUser?.emailVerified ?? false;
              // if (emailVerified) {
              //   return const Text(
              //       'Done'); // Placeholder container when email is verified
              // } else {
              //   // return const VerifyEmailView();
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     Navigator.of(context).push(MaterialPageRoute(
              //         builder: (_) => const VerifyEmailView()));
              //   });
              // }
              return  const LoginViewState();
            default:
              return const Text('Loading ...');
          }
        },
      ),
      backgroundColor: const Color.fromARGB(255, 180, 189, 197),
    );
  }
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailView();
}

class _VerifyEmailView extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Column(
        children: [
          const Text('Please verify your email'),
          TextButton(
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                await currentUser?.sendEmailVerification();
              },
              child: const Text('Send email verification'))
        ],
      ),
    );
  }
}
