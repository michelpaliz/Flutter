import 'package:first_project/b-backend/auth/auth_database/auth/auth_service.dart';
import 'package:first_project/c-frontend/b-group-section/screens/show-groups/show_groups.dart';
import 'package:first_project/e-drawer-style-menu/my_drawer.dart';
import 'package:flutter/material.dart';

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
      future: _initializeUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildUserDependentView();
        } else {
          return _buildLoadingIndicator();
        }
      },
    );
  }

  Future<void> _initializeUser() async {
    await AuthService.custom().initialize(); // ✅ Correct service call
  }

  Widget _buildUserDependentView() {
    final user = AuthService.custom().currentUser;

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
