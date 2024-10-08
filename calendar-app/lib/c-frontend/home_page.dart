
import 'package:first_project/b-backend/database_conection/auth_database/logic_backend/auth_provider.dart';
import 'package:first_project/styles/drawer-style-menu/my_drawer.dart';
import 'package:first_project/c-frontend/c-log-user-section/verify_email_view.dart';
import 'package:first_project/c-frontend/notes_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeUser(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildUserDependentView(context);
        } else {
          return _buildLoadingIndicator();
        }
      },
    );
  }

  Future<void> _initializeUser(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
  }

  Widget _buildUserDependentView(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (authProvider.currentUser == null) {
      return Center(
        child: Text('No user is currently logged in'),
      );
    }

    if (!authProvider.currentUser!.isEmailVerified) {
      return const VerifyEmailView();
    } else {
      return const NotesView();
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
