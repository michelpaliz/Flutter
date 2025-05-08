import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:first_project/b-backend/api/auth/auth_database/auth_service.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';

class LoginInitializer {
  final AuthService authService;
  final UserManagement userManagement;
  final GroupManagement groupManagement;

  User? _user;

  LoginInitializer({
    required this.authService,
    required this.userManagement,
    required this.groupManagement,
  });

  Future<void> initializeUserAndServices(String email, String password) async {
    await authService.logIn(email: email, password: password);
    final user = await authService.getCurrentUserModel();
    debugPrint('🔍 Got user from authService: $user');

    if (user != null) {
      if (authService.repository is AuthProvider) {
        final provider = authService.repository as AuthProvider;
        provider.currentUser = user; // ✅ Notifies listeners
      }

      _user = user;
      userManagement.setCurrentUser(user);
      groupManagement.setCurrentUser(user);
      debugPrint('✅ setCurrentUser called with: ${user.userName}');
    } else {
      debugPrint('❌ getCurrentUserModel returned null');
    }
  }

  User? get user => _user;
}
