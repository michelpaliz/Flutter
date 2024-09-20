import 'dart:convert';

import 'package:first_project/models/notification_user.dart';
import 'package:first_project/backend/custom_errors.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl =
      'http://192.168.1.16:3000/api/notifications'; // Replace with your API base URL

  Future<List<NotificationUser>> getAllNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => NotificationUser.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<NotificationUser> createNotification(
      NotificationUser notification) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(notification.toJson()),
      );

      if (response.statusCode == 201) {
        return NotificationUser.fromJson(jsonDecode(response.body));
      } else {
        throw CustomException(
          'Failed to create notification',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (error) {
      // Ensure you are not passing null or undefined values
      final errorMessage =
          error is CustomException ? error.message : 'Unknown error';
      final errorDetails = error is CustomException
          ? error.responseBody
          : 'No details available';

      throw CustomException(
        'Failed to create notification: $errorMessage. Details: $errorDetails',
        statusCode: error is CustomException ? error.statusCode : 500,
        responseBody: errorDetails,
      );
    }
  }

  Future<NotificationUser> getNotificationById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return NotificationUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get notification');
    }
  }

  Future<NotificationUser> updateNotification(
      NotificationUser notification) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${notification.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(notification.toJson()),
    );
    if (response.statusCode == 200) {
      return NotificationUser.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update notification');
    }
  }

  Future<bool> deleteNotification(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
    return true; // Assuming success if status code is 200
  }
}
