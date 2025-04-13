import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'package:dio/dio.dart';
import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'http://192.168.1.16:3000/api/users'; // Your server URL

  // Modify createUser to accept a User object and return User
  Future<User> createUser(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()), // Use User's toJson method
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body)); // Return User directly
    } else if (response.statusCode == 409) {
      throw Exception('User with this email or username already exists');
    } else {
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
      throw Exception('Failed to search users: ${response.reasonPhrase}');
    }
  }

  Future<User> getUserById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // Directly use User's fromJson method
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  Future<User> getUserByEmail(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/email/$email'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // Directly use User's fromJson method
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  Future<User> getUserByAuthID(String authID) async {
    final response = await http.get(Uri.parse('$baseUrl/authID/$authID'));

    devtools.log("THIS IS AUTH VALUE $authID");

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // Directly use User's fromJson method
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  // Update updateUser to accept a User object
  Future<User> updateUser(User user) async {
    var dio = Dio();
    try {
      var response = await dio.put(
        '$baseUrl/${user.id}', // Use user's id
        data: user.toJson(), // Use User's toJson method
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data); // Directly use User's fromJson method
      } else {
        print('Failed to update user: ${response.data}');
        throw Exception('Failed to update user: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioError) {
        print('DioError: ${e.message}');
        if (e.response != null) {
          print('Error Response: ${e.response?.data}');
          print('Error Status Code: ${e.response?.statusCode}');
          throw Exception('Failed to update user: ${e.response?.statusMessage}');
        } else {
          throw Exception('Network or server issue: ${e.message}');
        }
      } else {
        print('Unexpected error: $e');
        throw Exception('Failed to update user: $e');
      }
    }
  }

  Future<User> updateUserByUsername(String username, User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/username/$username'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()), // Use User's toJson method
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // Directly use User's fromJson method
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to update user: ${response.reasonPhrase}');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.reasonPhrase}');
    }
  }

  Future<List<User>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => User.fromJson(model)).toList(); // Directly map to List<User>
    } else {
      throw Exception('Failed to get users: ${response.reasonPhrase}');
    }
  }

  Future<User> getUserByUsername(String username) async {
    devtools.log('Get user by username $username');
    final response = await http.get(Uri.parse('$baseUrl/username/$username'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // Directly use User's fromJson method
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  Future<List<NotificationUser>> getNotificationsByUser(String userName) async {
    final response = await http.get(Uri.parse('$baseUrl/notifications/$userName'));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list.map((model) => NotificationUser.fromJson(model)).toList();
    } else {
      throw Exception('Failed to get notifications: ${response.reasonPhrase}');
    }
  }
}
