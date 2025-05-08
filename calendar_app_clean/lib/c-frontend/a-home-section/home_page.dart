import 'package:first_project/b-backend/api/auth/auth_database/auth_service.dart';
import 'package:first_project/c-frontend/b-group-section/screens/show-groups/show_groups.dart';
import 'package:first_project/e-drawer-style-menu/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Required for Provider access

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
    final authService =
        Provider.of<AuthService>(context, listen: false); // ✅ Injected

    return FutureBuilder<void>(
      future: _initializeUser(authService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildUserDependentView(authService);
        } else {
          return _buildLoadingIndicator();
        }
      },
    );
  }

  Future<void> _initializeUser(AuthService authService) async {
    await authService.initialize();
  }

  Widget _buildUserDependentView(AuthService authService) {
    final user = authService.currentUser;

    if (user == null) {
      return const Center(
        child: Text('No user is currently logged in'),
      );
    }

    return const ShowGroups();
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
