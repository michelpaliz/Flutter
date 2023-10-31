import 'package:first_project/costume_widgets/drawer/my_drawer.dart';
import 'package:first_project/services/auth/auth_exceptions.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:first_project/views/verify_email_view.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return buildBody();
            default:
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }

  Widget buildBody() {
    final authService = AuthService.firebase();
    final currentUser = authService.currentUser;
    if (currentUser == null) {
      throw new UserNotFoundAuthException();
    }
    return FutureBuilder(
      future: authService.generateUserCustomeModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final costumeUser = snapshot.data;
          authService.costumeUser = costumeUser;
          final emailVerified = currentUser.isEmailVerified;
          // devtools.log('Is verified ? $emailVerified');
          if (emailVerified) {
            return const NotesView();
          } else {
            return const VerifyEmailView();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
