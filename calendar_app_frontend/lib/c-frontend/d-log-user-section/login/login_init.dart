import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_service.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:calendar_app_frontend/b-backend/api/socket/socket_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/socket_notification_listener.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
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
        provider.currentUser = user;
      }

      _user = user;
      userManagement.setCurrentUser(user);
      groupManagement.setCurrentUser(user);
      debugPrint('✅ setCurrentUser called with: ${user.userName}');

      // ✅ Connect to the notification socket using user ID
      initializeNotificationSocket(user.id); // ← ADD THIS LINE

      // 🔐 Also connect other socket if using token
      final token = await TokenStorage.loadToken();
      if (token != null) {
        SocketManager().connect(token);
      } else {
        debugPrint('❌ No auth token found — cannot connect socket.');
      }
    } else {
      debugPrint('❌ getCurrentUserModel returned null');
    }
  }

  User? get user => _user;
}
