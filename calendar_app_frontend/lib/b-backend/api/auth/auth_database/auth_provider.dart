import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/exceptions/auth_exceptions.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_rotues.dart';
import 'package:calendar_app_frontend/b-backend/api/user/user_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../a-models/user_model/user.dart';
import 'auth_repository.dart';

class AuthProvider extends ChangeNotifier implements AuthRepository {
  final UserService _userService = UserService();
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  User? _user;
  String? _authToken;

  AuthProvider();

  @override
  User? get currentUser => _user;

  @override
  set currentUser(User? user) {
    _user = user;
    _authStateController.add(_user);
    notifyListeners();
  }

  Stream<User?> get authStateStream => _authStateController.stream;

  set customUser(User? userUpdated) {
    _user = userUpdated;
    _authStateController.add(_user);
    notifyListeners();
  }

  String? get lastToken => _authToken;

  @override
  Future<String> createUser({
    required String userName,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'userName': userName,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return 'User created successfully';
      } else {
        final errorMessage = data['message']?.toString().toLowerCase() ?? '';
        if (errorMessage.contains('email') &&
            errorMessage.contains('already')) {
          throw EmailAlreadyUseAuthException();
        } else if (errorMessage.contains('weak') ||
            errorMessage.contains('password')) {
          throw WeakPasswordException();
        } else if (errorMessage.contains('invalid') &&
            errorMessage.contains('email')) {
          throw InvalidEmailAuthException();
        } else {
          throw GenericAuthException();
        }
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<User?> logIn({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _authToken = data['accessToken'];
        await TokenStorage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        final userId = data['userId'];
        currentUser = await _userService.getUserById(userId);
        return _user;
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<void> logOut() async {
    _user = null;
    _authToken = null;
    await TokenStorage.clearTokens(); // Clear both tokens
    _authStateController.add(null);
    notifyListeners();
  }

  @override
  Future<void> sendEmailVerification() async {
    throw UnimplementedError("Handled by backend or removed entirely.");
  }

  @override
  Future<void> initialize() async {
    _authToken = await TokenStorage.loadToken();
    debugPrint('📥 Loaded access token: $_authToken');

    if (_authToken == null) {
      debugPrint('🚫 No access token found in secure storage.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/profile'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _user = User.fromJson(json);
        _authStateController.add(_user);
        debugPrint('✅ User fetched successfully on app launch.');
      } else if (response.statusCode == 401) {
        debugPrint('🔁 Access token expired. Trying refresh...');
        final refreshed = await _tryRefreshToken();
        if (!refreshed) {
          debugPrint(
              '❌ Token refresh failed — but NOT logging out automatically.');
          // 👇 Optional: notify UI to show login screen
          _authStateController.add(null);
        }
      } else {
        debugPrint(
            '⚠️ Unexpected status code during profile fetch: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('📡 Network error during profile fetch: $e');
      // DO NOT log out. Let user retry when network is restored.
      // You can show an offline screen, fallback view, or toast.
    }

    notifyListeners();
  }

  @override
  Future<User?> getCurrentUserModel() async {
    return _user;
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword != confirmPassword) {
      throw PasswordMismatchException();
    }
    if (_authToken == null) {
      throw UserNotSignedInException();
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Password change failed");
      }
    } catch (e) {
      throw Exception("Error changing password: $e");
    }
  }

  String generateCustomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        10,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await TokenStorage.loadRefreshToken();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _authToken = data['accessToken'];

      await TokenStorage.saveTokens(
        accessToken: _authToken!,
        refreshToken: refreshToken,
      );

      // Re-fetch the user profile
      final profileResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/profile'),
        headers: {'Authorization': 'Bearer $_authToken'},
      );

      if (profileResponse.statusCode == 200) {
        final json = jsonDecode(profileResponse.body);
        _user = User.fromJson(json);
        _authStateController.add(_user);
      }

      return true;
    }

    return false;
  }
}
