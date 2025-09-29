import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:hexora/a-models/group_model/calendar/calendar.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:hexora/b-backend/api/config/api_constants.dart';
import 'package:hexora/b-backend/api/group/error_classes/error_classes.dart';
import 'package:http/http.dart' as http;

class GroupService {
  final String baseUrl = '${ApiConstants.baseUrl}/groups';

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.loadToken();
    if (token == null) throw Exception("Authentication token not found");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  // Create a group directly with Group model
  Future<Group> createGroup(Group group) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: await _authHeaders(), // 🔐 Adds Authorization + Content-Type
      body: jsonEncode(group.toJsonForCreation()),
    );

    if (response.statusCode == 201) {
      final groupJson = jsonDecode(response.body);
      return Group.fromJson(groupJson);
    } else {
      throw Exception('Failed to create group: ${response.reasonPhrase}');
    }
  }

  Future<Group> getGroupById(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: await _authHeaders(),
    );

    devtools.log('📥 GET /groups/$id → ${res.statusCode}');
    devtools.log('📦 Body: ${res.body}');

    if (res.statusCode == 200 && res.body != 'null') {
      return Group.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 404) {
      throw NotFoundException('Group $id not found');
    }
    throw HttpFailure(
      res.statusCode,
      res.body.isEmpty ? 'Unknown error' : res.body,
    );
  }

  Future<void> leaveGroup(String userId, String groupId) async {
    final url = Uri.parse('$baseUrl/$groupId/users/$userId');

    final response = await http.delete(url, headers: await _authHeaders());

    if (response.statusCode != 200) {
      throw Exception('Failed to leave group: ${response.reasonPhrase}');
    }
  }

  // Update a group directly with Group model
  Future<bool> updateGroup(Group group) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${group.id}'),
      headers: await _authHeaders(),
      body: jsonEncode(group.toJson()), // Send Group as JSON
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update group: ${response.reasonPhrase}');
    }
  }

  // Delete a group by ID
  Future<void> deleteGroup(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: await _authHeaders(), // ✅ Use the helper here
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete group: ${response.reasonPhrase}');
    }
  }

  // Get all groups for a user, including fetching calendars for each group
  Future<List<Group>> getGroupsByUser(String userName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userName'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);

      // Create a list of futures to fetch calendars for each group
      List<Future<Group>> groupFutures = body.map<Future<Group>>((
        dynamic item,
      ) async {
        final groupJson = item;
        // Calendar calendar = await getCalendarById(groupJson['calendarId']);
        return Group.fromJson(groupJson); // Group without DTO
      }).toList();

      return await Future.wait(groupFutures); // Wait for all futures
    } else {
      throw Exception('Failed to load groups: ${response.reasonPhrase}');
    }
  }

  // Remove a user from a group by user ID and group ID
  Future<bool> removeUserInGroup(String userId, String groupId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$groupId/users/$userId'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        'Failed to remove user from group: ${response.reasonPhrase}',
      );
    }
  }

  // Get a calendar by its ID

  Future<Calendar> getCalendarById(String calendarId) async {
    final String calendarUrl = '${ApiConstants.baseUrl}/calendars/$calendarId';

    final response = await http.get(Uri.parse(calendarUrl));

    if (response.statusCode == 200) {
      final calendar = Calendar.fromJson(
        jsonDecode(response.body),
      ); // Assuming Calendar has a fromJson() method
      devtools.log('Fetched calendar: $calendar');
      return calendar;
    } else {
      throw Exception('Failed to get calendar: ${response.reasonPhrase}');
    }
  }

  Future<void> respondToInvite({
    required String groupId,
    required String username,
    required bool accepted,
  }) async {
    final url = Uri.parse('$baseUrl/invite/response'); // ✅ Correct path

    final response = await http.put(
      // ✅ Correct HTTP method
      url,
      headers: await _authHeaders(),
      body: jsonEncode({
        'groupId': groupId,
        'username': username,
        'accepted': accepted,
      }),
    );

    devtools.log(
      '📤 [GroupService] PUT /invite/response → Status: ${response.statusCode}',
    );
    devtools.log('📦 [GroupService] Payload: $groupId | $username | $accepted');

    if (response.statusCode != 200) {
      throw Exception(
        '❌ Failed to respond to invite: ${response.reasonPhrase}',
      );
    }
  }
}
