import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:first_project/models/user.dart';

class UserService {
 final String baseUrl = 'http://192.168.1.16:3000/api'; // Update with your server URL
  // ... // Replace with your server URL

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
    } else {
      throw Exception('Failed to create user');
    }
  }

  // Implement other methods for getting, updating, and deleting users
}
