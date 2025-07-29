import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static final _secureStorage = FlutterSecureStorage();

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _accessTokenKey, value: accessToken);
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    debugPrint(
        "🔐 Tokens saved: access=[$accessToken], refresh=[$refreshToken]");
  }

  static Future<String?> loadToken() async {
    final token = await _secureStorage.read(key: _accessTokenKey);
    debugPrint("📥 Loaded access token: $token");
    return token;
  }

  static Future<String?> loadRefreshToken() async {
    final refresh = await _secureStorage.read(key: _refreshTokenKey);
    debugPrint("📥 Loaded refresh token: $refresh");
    return refresh;
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    debugPrint("🧹 Cleared access and refresh tokens.");
  }
}
