import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:hexora/a-models/notification_model/notification_user.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:http/http.dart' as http;

class UserApiClient {
  final String baseUrl = '${ApiConstants.baseUrl}/users';

  Map<String, String> _headers({String? token, Map<String, String>? extra}) => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
        ...?extra,
      };

  // -------- Blobs / Avatars --------
  Future<String> getFreshAvatarUrl({
    required String blobName,
    required String token,
  }) async {
    final res = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/blobs/read-sas?blobName=${Uri.encodeComponent(blobName)}',
      ),
      headers: _headers(token: token, extra: {'Accept': 'application/json'}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is Map && data['url'] is String) return data['url'] as String;
      throw Exception('Unexpected response format: ${res.body}');
    }
    throw Exception(
        'Failed to refresh avatar URL: ${res.statusCode} ${res.reasonPhrase}');
  }

  // -------- Create / Read / Update / Delete --------
  Future<User> createUser(User user) async {
    final res = await http.post(
      Uri.parse(baseUrl),
      headers: _headers(),
      body: jsonEncode(user.toJson()),
    );
    if (res.statusCode == 201) {
      return User.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 409)
      throw Exception('User with this email or username already exists');
    throw Exception(
        'Failed to create user: ${res.statusCode} ${res.reasonPhrase}');
  }

  Future<User> getUserById(String userId, {required String token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$userId'),
      headers: _headers(token: token),
    );

    devtools.log('👤 GET /users/$userId → ${res.statusCode}');
    devtools.log('👤 body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch user with id: $userId');
    }

    final decoded = jsonDecode(res.body);
    return User.fromJson(decoded, fallbackId: userId);
  }

  Future<User> getUserByEmail(String email, {String? token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/email/$email'),
      headers: _headers(token: token),
    );
    if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
    if (res.statusCode == 404) throw Exception('User not found');
    throw Exception(
        'Failed to get user: ${res.statusCode} ${res.reasonPhrase}');
  }

  Future<User> getUserByAuthID(String authID, {String? token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/authID/$authID'),
      headers: _headers(token: token),
    );

    devtools.log("THIS IS AUTH VALUE $authID");

    if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
    if (res.statusCode == 404) throw Exception('User not found');
    throw Exception(
        'Failed to get user: ${res.statusCode} ${res.reasonPhrase}');
  }

  Future<User> updateUser(User user, {required String token}) async {
    final res = await http.put(
      Uri.parse('$baseUrl/${user.id}'),
      headers: _headers(token: token),
      body: jsonEncode(user.toJson()),
    );

    if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
    throw Exception(
        'Failed to update user: ${res.statusCode} ${res.reasonPhrase}');
  }

  Future<User> updateUserByUsername(String username, User user,
      {required String token}) async {
    final res = await http.put(
      Uri.parse('$baseUrl/username/$username'),
      headers: _headers(token: token),
      body: jsonEncode(user.toJson()),
    );

    if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
    if (res.statusCode == 404) throw Exception('User not found');
    throw Exception(
        'Failed to update user: ${res.statusCode} ${res.reasonPhrase}');
  }

  Future<void> deleteUser(String id, {required String token}) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: _headers(token: token),
    );
    if (res.statusCode != 200) {
      throw Exception(
          'Failed to delete user: ${res.statusCode} ${res.reasonPhrase}');
    }
  }

  Future<List<User>> getAllUsers({String? token}) async {
    final res = await http.get(
      Uri.parse(baseUrl),
      headers: _headers(token: token),
    );

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((m) => User.fromJson(m)).toList();
    }
    throw Exception(
        'Failed to get users: ${res.statusCode} ${res.reasonPhrase}');
  }

  // -------- Lookups --------
  Future<User> getUserByUsername(String username, {String? token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/username/$username'),
      headers: _headers(token: token),
    );

    if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
    if (res.statusCode == 404) throw Exception('User not found');
    throw Exception(
        'Failed to get user: ${res.statusCode} ${res.reasonPhrase}');
  }

  /// Returns usernames (strings). If you later expose a rich endpoint, add another method.
  Future<List<String>> searchUsernames(String username, {String? token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/search/${Uri.encodeComponent(username)}'),
      headers: _headers(token: token),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      if (data is List) return List<String>.from(data);
      if (data is Map && data.containsKey('message')) {
        // keep compatibility with your existing behavior
        return const <String>[];
      }
      throw Exception('Unexpected response format');
    }
    throw Exception(
        'Failed to search users: ${res.statusCode} ${res.reasonPhrase}');
  }

  // -------- Notifications --------
  Future<List<NotificationUser>> getNotificationsByUser(String userName,
      {required String token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/notifications/$userName'),
      headers: _headers(token: token),
    );

    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((m) => NotificationUser.fromJson(m)).toList();
    }
    throw Exception(
        'Failed to get notifications: ${res.statusCode} ${res.reasonPhrase}');
  }

  // -------- Generic selector --------
  Future<User> getUserBySelector(String selector, {String? token}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/by/${Uri.encodeComponent(selector)}'),
      headers: _headers(token: token),
    );

    devtools.log('👤 GET /users/by/$selector → ${res.statusCode}');
    devtools.log('👤 body: ${res.body}');

    if (res.statusCode == 200) return User.fromJson(jsonDecode(res.body));
    if (res.statusCode == 404) throw Exception('User not found');
    if (res.statusCode == 400) throw Exception('Invalid selector');
    throw Exception(
        'Failed to fetch user: ${res.statusCode} ${res.reasonPhrase}');
  }
}
