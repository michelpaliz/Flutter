import 'package:first_project/services/firebase_%20services/auth/exceptions/auth_exceptions.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/styles/drawer-style-menu/my_drawer.dart';
import 'package:first_project/views/log-user/verify_email_view.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildUserDependentView(context);
        } else {
          return _buildLoadingIndicator();
        }
      },
    );
  }

  Widget _buildUserDependentView(BuildContext context) {
    final authService = AuthService.firebase();
    var currentUser = authService.currentUser;

    if (currentUser == null) {
      throw UserNotFoundAuthException();
    }

    final costumeUser = authService.costumeUser;
    if (costumeUser == null) {
      return _buildLoadingIndicator();
    }

    if (currentUser.isEmailVerified) {
      return const NotesView();
    } else {
      return const VerifyEmailView();
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
