import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_service.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:calendar_app_frontend/b-backend/api/socket/socket_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/socket_notification_listener.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';

// Import or replace with your actual constants location
class ApiConstants {
  static const bool avatarsArePublic = true; // set from backend config
  static const String cdnBaseUrl =
      'https://mantemichelstore.blob.core.windows.net/profile-images';
}

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
    final rawUser = await authService.getCurrentUserModel();
    debugPrint('🔍 Got user from authService: $rawUser');

    if (rawUser != null) {
      // 🔧 Normalize photoUrl in public avatar mode
      final normalizedUser = ApiConstants.avatarsArePublic
          ? rawUser.copyWith(
              photoUrl: _normalizePublicAvatar(rawUser.photoUrl ?? ''))
          : rawUser;

      if (authService.repository is AuthProvider) {
        final provider = authService.repository as AuthProvider;
        provider.currentUser = normalizedUser;
      }

      _user = normalizedUser;

      final token = await TokenStorage.loadToken();

      // ✅ Pass normalized user to state management
      userManagement.setCurrentUser(normalizedUser, authToken: token);
      groupManagement.setCurrentUser(normalizedUser);

      debugPrint('✅ setCurrentUser called with: ${normalizedUser.userName}');

      initializeNotificationSocket(normalizedUser.id);

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

  /// Ensures `photoUrl` is in `${CDN_BASE_URL}/<blobName>` format without query params.
  String _normalizePublicAvatar(String photoUrl) {
    if (photoUrl.isEmpty) return photoUrl;

    final uri = Uri.tryParse(photoUrl);
    if (uri == null) return photoUrl;

    final alreadyCdn =
        photoUrl.startsWith(ApiConstants.cdnBaseUrl) && !uri.hasQuery;
    if (alreadyCdn) return photoUrl;

    final segments = uri.pathSegments;
    if (segments.isEmpty) return photoUrl;

    final blobName = segments.last;
    if (blobName.isEmpty) return photoUrl;

    return '${ApiConstants.cdnBaseUrl}/$blobName';
  }
}
