import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/auth_user/auth/auth_database/api/i_auth_api_client.dart';
import 'package:hexora/b-backend/auth_user/auth/auth_database/auth_repository.dart';
// NOTE: keep this import matching your project structure:
import 'package:hexora/b-backend/auth_user/auth/auth_database/token/token_storage.dart';
import 'package:hexora/b-backend/auth_user/auth/exceptions/auth_exceptions.dart';
import 'package:hexora/b-backend/auth_user/user/repository/i_user_repository.dart';

class AuthProvider extends ChangeNotifier implements AuthRepository {
  final IUserRepository _userRepo;
  final IAuthApiClient _authApi; // ← inject API client

  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  User? _user;
  String? _authToken;

  AuthProvider({
    required IUserRepository userRepository,
    required IAuthApiClient authApi,
  })  : _userRepo = userRepository,
        _authApi = authApi;

  @override
  User? get currentUser => _user;

  @override
  set currentUser(User? user) {
    _user = user;
    _authStateController.add(_user);
    notifyListeners();
  }

  Stream<User?> get authStateStream => _authStateController.stream;

  String? get lastToken => _authToken;

  @override
  Future<String> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final res =
        await _authApi.register(name: name, email: email, password: password);
    final status = res['_status'] as int? ?? 201;
    if (status == 201) return 'User created successfully';

    final errorMessage = (res['message']?.toString() ?? '').toLowerCase();
    if (errorMessage.contains('email') && errorMessage.contains('already')) {
      throw EmailAlreadyUseAuthException();
    } else if (errorMessage.contains('weak') ||
        errorMessage.contains('password')) {
      throw WeakPasswordException();
    } else if (errorMessage.contains('invalid') &&
        errorMessage.contains('email')) {
      throw InvalidEmailAuthException();
    }
    throw GenericAuthException();
  }

  // --------------------------------------------------------------------------
  // LOGIN: accept both camelCase and snake_case keys from the backend
  // --------------------------------------------------------------------------
  @override
  Future<User?> logIn({required String email, required String password}) async {
    final data = await _authApi.login(email: email, password: password);

    final status = data['_status'] as int? ?? 200;
    if (status != 200) {
      final msg = data['message']?.toString() ?? 'Login failed';
      throw Exception(msg);
    }

    // Accept both camelCase and snake_case
    final String? accessToken =
        (data['accessToken'] ?? data['access_token']) as String?;
    final String? refreshToken =
        (data['refreshToken'] ?? data['refresh_token']) as String?;
    final String? userId = (data['userId'] ?? data['id']) as String?;

    if (accessToken == null || refreshToken == null || userId == null) {
      throw FormatException('Missing required fields in login response');
    }

    _authToken = accessToken;
    await TokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final user = await _userRepo.getUserById(userId);
    currentUser = user;
    return _user;
  }

  @override
  Future<void> logOut() async {
    _user = null;
    _authToken = null;
    await TokenStorage.clearTokens();
    _authStateController.add(null);
    notifyListeners();
  }

  @override
  Future<void> sendEmailVerification() async {
    throw UnimplementedError('Handled by backend or removed entirely.');
  }

  // --------------------------------------------------------------------------
  // STARTUP: try to restore session from stored access token; refresh if 401
  // --------------------------------------------------------------------------
  @override
  Future<void> initialize() async {
    _authToken = await TokenStorage.loadToken();
    // debugPrint('Init: token loaded? ${_authToken != null}');

    if (_authToken == null) {
      notifyListeners();
      return;
    }

    final prof = await _authApi.profile(accessToken: _authToken!);
    final status = prof['_status'] as int? ?? 200;
    // debugPrint('Init: /profile _status=$status');

    if (status == 200) {
      _user = User.fromJson(prof);
      _authStateController.add(_user);
    } else if (status == 401) {
      final refreshed = await _tryRefreshToken();
      if (!refreshed) _authStateController.add(null);
    }

    notifyListeners();
  }

  @override
  Future<User?> getCurrentUserModel() async => _user;

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword != confirmPassword) throw PasswordMismatchException();
    if (_authToken == null) throw UserNotSignedInException();

    await _authApi.changePassword(
      accessToken: _authToken!,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<String?> getToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    final stored = await TokenStorage.loadToken();
    if (stored != null && stored.isNotEmpty) {
      _authToken = stored;
      return stored;
    }
    return null;
  }

  // --------------------------------------------------------------------------
  // REFRESH: accept both camelCase and snake_case from refresh endpoint too
  // --------------------------------------------------------------------------
  Future<bool> _tryRefreshToken() async {
    final refreshToken = await TokenStorage.loadRefreshToken();
    if (refreshToken == null) return false;

    // debugPrint('Refresh: trying with saved refresh token...');
    final data = await _authApi.refresh(refreshToken: refreshToken);
    final status = data['_status'] as int? ?? 200;
    // debugPrint('Refresh: _status=$status');
    if (status != 200) return false;

    // accept both accessToken and access_token
    _authToken = ((data['accessToken'] ?? data['access_token']) as String?);
    if (_authToken == null) return false;

    // If your backend also rotates refresh token, accept both casings:
    final rotatedRefresh =
        (data['refreshToken'] ?? data['refresh_token']) as String? ??
            refreshToken;

    await TokenStorage.saveTokens(
      accessToken: _authToken!,
      refreshToken: rotatedRefresh,
    );

    final prof = await _authApi.profile(accessToken: _authToken!);
    if ((prof['_status'] as int? ?? 200) == 200) {
      _user = User.fromJson(prof);
      _authStateController.add(_user);
    }

    return true;
  }

  @override
  void dispose() {
    _authStateController.close();
    super.dispose();
  }
}
