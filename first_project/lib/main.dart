import 'dart:developer' as devtools show log;
import 'package:first_project/constants/routes.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/views/add_note.dart';
import 'package:first_project/views/login_view.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:first_project/views/register_view.dart';
import 'package:first_project/views/verify_email_view.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.firebase().initialize(); // Initialize Firebase
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginViewState(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        addNote : (context) => EventNoteWidget()
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final currentUser = AuthService.firebase().currentUser;
            if (currentUser != null) {
              final emailVerified = currentUser.isEmailVerified;
              devtools.log('Is verified ? $emailVerified');
              if (emailVerified) {
                return const NotesView();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginViewState();
            }
          default:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
