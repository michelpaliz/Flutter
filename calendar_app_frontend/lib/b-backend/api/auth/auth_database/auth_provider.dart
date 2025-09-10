import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/exceptions/auth_exceptions.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
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
  @override
  Future<User?> logIn({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // 🔍 Debug logs
      debugPrint('🔐 /auth/login → ${response.statusCode}');
      debugPrint('🔐 body: ${response.body}');

      final data = jsonDecode(response.body);

      String _mask(String? v) => v == null
          ? 'null'
          : (v.length <= 8
              ? v
              : '${v.substring(0, 4)}…${v.substring(v.length - 4)}');

      if (response.statusCode != 200) {
        final msg = (data is Map<String, dynamic>)
            ? (data['message']?.toString() ?? 'Login failed')
            : 'Login failed';
        throw Exception(msg);
      }

      // ✅ Validate required fields
      final accessToken = (data is Map<String, dynamic>)
          ? data['accessToken'] as String?
          : null;
      final refreshToken = (data is Map<String, dynamic>)
          ? data['refreshToken'] as String?
          : null;
      final userId =
          (data is Map<String, dynamic>) ? data['userId'] as String? : null;

      debugPrint('🔐 parsed login: {'
          'userId: $userId, '
          'accessToken: ${_mask(accessToken)}, '
          'refreshToken: ${_mask(refreshToken)} }');

      if (accessToken == null || refreshToken == null || userId == null) {
        throw FormatException("Missing required fields in login response: "
            "accessToken=${accessToken != null}, "
            "refreshToken=${refreshToken != null}, "
            "userId=${userId != null}");
      }

      // ✅ Save tokens after validation
      _authToken = accessToken;
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // ✅ Fetch the user; if something crashes in parsing, we’ll see the real line
      debugPrint('👤 fetching user by id: $userId');
      final user = await _userService.getUserById(userId);
      debugPrint('👤 getUserById returned: ${user}');

      currentUser = user;
      return _user;
    } on TypeError catch (e, st) {
      // 🧯 Keep the original stack (so you see the exact file:line that failed)
      debugPrint('🧨 TypeError during login flow: $e');
      debugPrintStack(stackTrace: st);
      Error.throwWithStackTrace(Exception('Login error: $e'), st);
    } on FormatException catch (e, st) {
      debugPrint('🧨 FormatException during login flow: $e');
      debugPrintStack(stackTrace: st);
      Error.throwWithStackTrace(Exception('Login error: $e'), st);
    } catch (e, st) {
      debugPrint('🧨 Unknown login error: $e');
      debugPrintStack(stackTrace: st);
      Error.throwWithStackTrace(Exception('Login error: $e'), st);
    }
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

      // 🔍 Debug logs
      debugPrint('👤 GET /profile → ${response.statusCode}');
      debugPrint('👤 body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json is Map) {
          debugPrint('👤 profile keys: ${json.keys.toList()}');
        } else {
          debugPrint('👤 profile is not a Map, got: ${json.runtimeType}');
        }

        _user = User.fromJson(json);
        _authStateController.add(_user);
        debugPrint('✅ User fetched successfully on app launch.');
      } else if (response.statusCode == 401) {
        debugPrint('🔁 Access token expired. Trying refresh...');
        final refreshed = await _tryRefreshToken();
        if (!refreshed) {
          debugPrint(
              '❌ Token refresh failed — but NOT logging out automatically.');
          _authStateController.add(null);
        }
      } else {
        debugPrint(
            '⚠️ Unexpected status code during profile fetch: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('📡 Network error during profile fetch: $e');
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

      debugPrint('👤 (refresh) GET /profile → ${profileResponse.statusCode}');
      debugPrint('👤 (refresh) body: ${profileResponse.body}');

      if (profileResponse.statusCode == 200) {
        final json = jsonDecode(profileResponse.body);
        _user = User.fromJson(json);
        _authStateController.add(_user);
      }

      return true;
    }

    return false;
  }

  @override
  Future<String?> getToken() async {
    // Return in-memory token if we have it
    if (_authToken != null && _authToken!.isNotEmpty) {
      return _authToken;
    }

    // Fallback: try secure storage
    final stored = await TokenStorage.loadToken();
    if (stored != null && stored.isNotEmpty) {
      _authToken = stored;
      return stored;
    }

    // (Optional) Try refresh flow if you want to be fancy:
    // final refreshed = await _tryRefreshToken();
    // return refreshed ? _authToken : null;

    return null;
  }
}
