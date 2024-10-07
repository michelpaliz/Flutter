import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:dio/dio.dart';
import 'package:first_project/a-models/model/DTO/userDTO.dart';
import 'package:first_project/a-models/model/user_data/notification_user.dart';
import 'package:first_project/a-models/model/user_data/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl =
      'http://192.168.1.16:3000/api/users'; // Your server URL

  // Modify createUser to accept UserDTO and return User
  Future<User> createUser(UserDTO userDTO) async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userDTO.toJson()), // Use UserDTO's toJson()
    );

    if (response.statusCode == 201) {
      final createdUserDTO = UserDTO.fromJson(jsonDecode(response.body));
      return createdUserDTO.toUser(); // Convert to User
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
      final userDTO =
          UserDTO.fromJson(jsonDecode(response.body)); // Get UserDTO
      return userDTO.toUser(); // Convert to User
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  Future<User> getUserByEmail(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/email/$email'));

    if (response.statusCode == 200) {
      final userDTO =
          UserDTO.fromJson(jsonDecode(response.body)); // Get UserDTO
      return userDTO.toUser(); // Convert to User
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
      final userDTO =
          UserDTO.fromJson(jsonDecode(response.body)); // Get UserDTO
      return userDTO.toUser(); // Convert to User
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to get user: ${response.reasonPhrase}');
    }
  }

  Future<User> updateUser(UserDTO userDTO) async {
    var dio = Dio();
    try {
      var response = await dio.put(
        '$baseUrl/${userDTO.id}',
        data: userDTO.toJson(), // Use UserDTO's toJson()
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200) {
        final updatedUserDTO =
            UserDTO.fromJson(response.data); // Get updated UserDTO
        return updatedUserDTO.toUser(); // Convert to User
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
          throw Exception(
              'Failed to update user: ${e.response?.statusMessage}');
        } else {
          throw Exception('Network or server issue: ${e.message}');
        }
      } else {
        print('Unexpected error: $e');
        throw Exception('Failed to update user: $e');
      }
    }
  }

  Future<User> updateUserByUsername(String username, UserDTO userDTO) async {
    final response = await http.put(
      Uri.parse('$baseUrl/username/$username'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userDTO.toJson()), // Use UserDTO's toJson()
    );

    if (response.statusCode == 200) {
      final updatedUserDTO =
          UserDTO.fromJson(jsonDecode(response.body)); // Get updated UserDTO
      return updatedUserDTO.toUser(); // Convert to User
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

  Future<List<UserDTO>> getAllUsers() async {
    final response = await http.get(Uri.parse('$baseUrl'));

    if (response.statusCode == 200) {
      Iterable list = json.decode(response.body);
      return list
          .map((model) => UserDTO.fromJson(model))
          .toList(); // Returns List<UserDTO>
    } else {
      throw Exception('Failed to get users: ${response.reasonPhrase}');
    }
  }

  Future<User> getUserByUsername(String username) async {
    devtools.log('Get user by username $username');
    final response = await http.get(Uri.parse('$baseUrl/username/$username'));

    if (response.statusCode == 200) {
      final userDTO =
          UserDTO.fromJson(jsonDecode(response.body)); // Get UserDTO
      return userDTO.toUser(); // Convert to User
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
