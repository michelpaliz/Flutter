import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/c-frontend/b-group-section/screens/show-groups/show_groups.dart';
import 'package:first_project/e-drawer-style-menu/my_drawer.dart';
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
    final user = authProvider.currentUser;

    if (user == null) {
      return const Center(
        child: Text('No user is currently logged in'),
      );
    }

    // ✅ You could add a custom check here if your backend supports email verification
    // if (!user.emailVerified) { return VerifyEmailView(); }

    return const ShowGroups();
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
