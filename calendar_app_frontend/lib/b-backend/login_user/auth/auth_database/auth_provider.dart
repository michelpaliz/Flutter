import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/token_storage.dart';
import 'package:hexora/b-backend/login_user/auth/exceptions/auth_exceptions.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:hexora/b-backend/login_user/user/repository/user_repository.dart'; // ✅ added
import 'package:hexora/b-backend/login_user/user/api/user_api_client.dart';
import 'package:http/http.dart' as http;

import '../../../../a-models/user_model/user.dart';
import 'auth_repository.dart';

class AuthProvider extends ChangeNotifier implements AuthRepository {
  // Replace direct service calls with a repository that injects the token for you.
  final UserRepository _userRepo = UserRepository(UserApiClient()); // ✅ new
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
  Future<User?> logIn({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

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

      final accessToken = (data is Map<String, dynamic>)
          ? data['accessToken'] as String?
          : null;
      final refreshToken = (data is Map<String, dynamic>)
          ? data['refreshToken'] as String?
          : null;
      final userId =
          (data is Map<String, dynamic>) ? data['userId'] as String? : null;

      debugPrint('🔐 parsed login: { userId: $userId, '
          'accessToken: ${_mask(accessToken)}, refreshToken: ${_mask(refreshToken)} }');

      if (accessToken == null || refreshToken == null || userId == null) {
        throw FormatException("Missing required fields in login response");
      }

      // Save tokens first so repository calls have a token to read
      _authToken = accessToken;
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // ✅ Fetch user via repository (handles token)
      debugPrint('👤 fetching user by id via repository: $userId');
      final user = await _userRepo.getUserById(userId);
      debugPrint('👤 getUserById returned: $user');

      currentUser = user;
      return _user;
    } on TypeError catch (e, st) {
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

      debugPrint('👤 GET /profile → ${response.statusCode}');
      debugPrint('👤 body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _user = User.fromJson(json);
        _authStateController.add(_user);
        debugPrint('✅ User fetched successfully on app launch.');
      } else if (response.statusCode == 401) {
        debugPrint('🔁 Access token expired. Trying refresh...');
        final refreshed = await _tryRefreshToken();
        if (!refreshed) {
          debugPrint('❌ Token refresh failed — not logging out automatically.');
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
  Future<User?> getCurrentUserModel() async => _user;

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    if (newPassword != confirmPassword) throw PasswordMismatchException();
    if (_authToken == null) throw UserNotSignedInException();

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
  }

  String generateCustomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          10, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
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
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    final stored = await TokenStorage.loadToken();
    if (stored != null && stored.isNotEmpty) {
      _authToken = stored;
      return stored;
    }
    return null;
  }
}
