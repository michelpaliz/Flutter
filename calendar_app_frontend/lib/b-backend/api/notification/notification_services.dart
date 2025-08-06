import 'dart:convert';

import 'package:calendar_app_frontend/b-backend/api/auth/exceptions/exception.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_rotues.dart';
import 'package:http/http.dart' as http;

import '../../../a-models/notification_model/notification_user.dart'; // Update this import based on your file structure

class NotificationService {
   final String baseUrl = '${ApiConstants.baseUrl}/notifications';


  Future<List<NotificationUser>> getAllNotifications() async {
    final response = await http.get(Uri.parse('$baseUrl/'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData
          .map((data) => NotificationUser.fromJson(data))
          .toList(); // Convert to List<NotificationUser>
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<List<NotificationUser>> getNotificationsForUser(
      String username) async {
    final url = Uri.parse('$baseUrl/user/$username');
    print('📡 GET: $url');

    final response = await http.get(url);

    print('📬 Status: ${response.statusCode}');
    print('📦 Body: ${response.body}');

    if (response.statusCode == 200) {
      final body = response.body;
      try {
        final List<dynamic> jsonData = jsonDecode(body);
        return jsonData.map((data) => NotificationUser.fromJson(data)).toList();
      } catch (e) {
        print('❌ Failed to parse notifications JSON: $e');
        throw Exception('Invalid response format');
      }
    } else if (response.statusCode == 404) {
      print('ℹ️ No notifications found for user: $username');
      return []; // Don't throw — just return empty
    } else {
      throw Exception(
          'Failed to fetch user notifications: ${response.statusCode}');
    }
  }

  Future<NotificationUser> createNotification(
    NotificationUser notification,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
          notification.toJsonForCreation(),
        ), // Use NotificationUser's toJson method
      );

      if (response.statusCode == 201) {
        return NotificationUser.fromJson(
          jsonDecode(response.body),
        ); // Convert back to NotificationUser
      } else {
        throw CustomException(
          'Failed to create notification',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }
    } catch (error) {
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

    // 🐞 Debug log with icon
    print('🐛 [GET Notification] Status: ${response.statusCode}');
    print('📦 [GET Notification] Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded == null || decoded is! Map<String, dynamic>) {
        throw Exception('Invalid response format: expected JSON object');
      }

      return NotificationUser.fromJson(decoded);
    } else if (response.statusCode == 404) {
      throw Exception('Notification not found');
    } else {
      throw Exception('Failed to get notification: ${response.statusCode}');
    }
  }

  Future<NotificationUser> updateNotification(
    NotificationUser notification,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${notification.id}'), // Use notification's id
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        notification.toJson(),
      ), // Use NotificationUser's toJson method
    );
    if (response.statusCode == 200) {
      return NotificationUser.fromJson(
        jsonDecode(response.body),
      ); // Convert back to NotificationUser
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
