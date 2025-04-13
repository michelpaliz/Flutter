import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:first_project/b-backend/auth/auth_database/exceptions/auth_exceptions.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
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

  @override
  Future<String> createUser({
    required String userName,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://your-backend-url/api/auth/register'),
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
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Error registering: $e');
    }
  }

  @override
  Future<User?> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://your-backend-url/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _authToken = data['token'];
        final userId = data['userId'];

        // Optional: fetch full user from backend
        _user = await _userService.getUserById(userId);
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
    _authStateController.add(null);
    notifyListeners();
  }

  @override
  Future<void> sendEmailVerification() async {
    throw UnimplementedError("Handled by backend or removed entirely.");
  }

  @override
  Future<void> initialize() async {
    // Optionally load auth token from local storage
    // and restore user session
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
        Uri.parse('http://your-backend-url/api/auth/change-password'),
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
          10, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }
}
