import 'dart:convert';

import 'package:first_project/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl =
      'http://192.168.1.16:3000/api'; // Update with your server URL

  Future<User> registerUserOnServer(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
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
      // Handle other errors
      throw Exception('Failed to create user: ${response.reasonPhrase}');
    }
  }

  // Implement other methods for getting, updating, and deleting users
}
