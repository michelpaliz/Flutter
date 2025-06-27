// lib/b-backend/auth/auth_service.dart
import 'dart:convert';
import 'package:calendar_app_frontend/b-backend/api/config/api_client.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/exceptions/auth_exceptions.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<String> registerUser({
    required String name,
    required String email,
    required String userName,
    required String password,
  }) async {
    final response = await _api.post('/auth/register', {
      'name': name,
      'email': email,
      'userName': userName,
      'password': password,
    });

    final json = jsonDecode(response.body);

    switch (response.statusCode) {
      case 201:
        return json['message'];
      case 400:
        throw EmailAlreadyUseAuthException();
      default:
        throw GenericAuthException();
    }
  }

  Future<String> logIn({
    required String email,
    required String password,
  }) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final json = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
        return json['token'];
      case 401:
        throw WrongPasswordAuthException();
      case 404:
        throw UserNotFoundAuthException();
      default:
        throw GenericAuthException();
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await _api.get(
      '/profile',
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw GenericAuthException();
    }
  }
}
