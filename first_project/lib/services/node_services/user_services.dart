import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:dio/dio.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl =
      'http://192.168.1.16:3000/api/users'; // Update with your server URL

  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 409) {
      // Handle conflict error (e.g., duplicate user)
      throw Exception('User with this email or username already exists');
    } else {
      // Log the detailed error response
      print('Failed to create user: ${response.reasonPhrase}');
      throw Exception('Failed to create user: ${response.reasonPhrase}');
    }
  }

  Future<dynamic> searchUsers(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search/${Uri.encodeComponent(username)}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return List<String>.from(data);
      } else if (data is Map && data.containsKey('message')) {
        return data;
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      // Handle other errors
      throw Exception('Failed to search users: ${response.reasonPhrase}');
    }
  }

// Get user by ID
  Future<User> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

// Get user by ID
  Future<User> getUserByEmail(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/email/$email'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  Future<User> getUserByAuthID(String authID) async {
    final response = await http.get(Uri.parse('$baseUrl/authID/$authID'));

    devtools.log("THIS IS AUTH VALUE ${authID}");

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  Future<User> updateUser(User user) async {
    var dio = Dio();
    try {
      var response = await dio.put(
        '$baseUrl/${user.id}',
        data: user.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Failed to update user: ${response.statusMessage}');
      }
    } catch (e) {
      print('Request error: $e');
      throw Exception('Failed to update user');
    }
  }

  // Update user by username
  Future<User> updateUserByUsername(String username, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/username/$username'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to update user: ${response.reasonPhrase}');
    }
  }

// Delete user
  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.reasonPhrase}');
    }
  }

// Get all users
  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => User.fromJson(model)).toList();
    } else {
      throw Exception('Failed to get users: ${response.reasonPhrase}');
    }
  }

  // Get user by username
  Future<User> getUserByUsername(String username) async {
    devtools.log('Get user by username $username');
    final response = await http.get(Uri.parse('$baseUrl/username/$username'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  Future<List<NotificationUser>> getNotificationsByUser(String userName) async {
    final response =
        await http.get(Uri.parse('$baseUrl/notifications/$userName'));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => NotificationUser.fromJson(model)).toList();
    } else {
      throw Exception('Failed to get notifications: ${response.reasonPhrase}');
    }
  }
}
