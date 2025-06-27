import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:calendar_app_frontend/b-backend/api/config/api_rotues.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/exceptions/auth_exceptions.dart';
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

  // Add this getter at the bottom of your AuthProvider class
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
      debugPrint("👀 Registration response body: $data"); // ✅ ADD THIS LINE
      debugPrint(
        "📤 Sending registration request: ${jsonEncode({'name': name, 'email': email, 'userName': userName, 'password': password})}",
      );

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
          debugPrint('⚠️ Unmatched error message: $errorMessage');
          throw GenericAuthException();
        }
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Registration error: $e");
      debugPrintStack(stackTrace: stackTrace);
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

      debugPrint("📥 Login response status: ${response.statusCode}");
      debugPrint("📥 Login response body: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _authToken = data['token'];
        await TokenStorage.saveToken(_authToken!);

        final userId = data['userId'];
        // _user = await _userService.getUserById(userId);
        currentUser = await _userService.getUserById(userId);
        _authStateController.add(_user);
        notifyListeners();

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
    await TokenStorage.clearToken();
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

    if (_authToken != null) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConstants.baseUrl}/profile'),
          headers: {'Authorization': 'Bearer $_authToken'},
        );

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          _user = User.fromJson(json);
          _authStateController.add(_user);
        }
      } catch (_) {
        await logOut(); // If token is invalid
      }

      notifyListeners();
    }
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
}
