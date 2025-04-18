import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';

class LoginInitializer {
  final AuthProvider authProvider;
  final UserManagement userManagement;
  final GroupManagement groupManagement; // ✅ Add this

  User? _user;

  LoginInitializer({
    required this.authProvider,
    required this.userManagement,
    required this.groupManagement, // ✅ Add this
  });

  Future<void> initializeUserAndServices(String email, String password) async {
    await authProvider.logIn(email: email, password: password);
    final user = await authProvider.getCurrentUserModel();
    debugPrint('🔍 Got user from authProvider: $user');

    if (user != null) {
      authProvider.currentUser = user;
      _user = user;
      userManagement.setCurrentUser(user);
      groupManagement.setCurrentUser(user); // ✅ Critical line here
      debugPrint('✅ setCurrentUser called with: ${user.userName}');
    } else {
      debugPrint('❌ getCurrentUserModel returned null');
    }
  }

  User? get user => _user;
}
