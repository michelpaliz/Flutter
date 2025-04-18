import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/group_model/calendar/calendar.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:http/http.dart' as http;

class GroupService {
  final String baseUrl =
      'http://192.168.1.16:3000/api/groups'; // Your server URL

  // Create a group directly with Group model
  Future<Group> createGroup(Group group) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(group.toJson()),
    );

    if (response.statusCode == 201) {
      final groupJson = jsonDecode(response.body);
      return Group.fromJson(groupJson); // return the full group
    } else {
      throw Exception('Failed to create group: ${response.reasonPhrase}');
    }
  }

  // Get a group by its ID, and fetch the related calendar directly
  Future<Group> getGroupById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200 && response.body != 'null') {
      final groupJson = jsonDecode(response.body);
      return Group.fromJson(groupJson);
    } else if (response.statusCode == 404) {
      throw Exception('Group not found');
    } else {
      throw Exception('Failed to get group: ${response.reasonPhrase}');
    }
  }

  // Update a group directly with Group model
  Future<bool> updateGroup(Group group) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${group.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
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
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete group: ${response.reasonPhrase}');
    }
  }

  // Get all groups for a user, including fetching calendars for each group
  Future<List<Group>> getGroupsByUser(String userName) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userName'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);

      // Create a list of futures to fetch calendars for each group
      List<Future<Group>> groupFutures =
          body.map<Future<Group>>((dynamic item) async {
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
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
          'Failed to remove user from group: ${response.reasonPhrase}');
    }
  }

  // Get a calendar by its ID
  Future<Calendar> getCalendarById(String calendarId) async {
    final String calendarUrl =
        'http://192.168.1.16:3000/api/calendars/$calendarId'; // URL for calendar API

    final response = await http.get(Uri.parse(calendarUrl));

    if (response.statusCode == 200) {
      final calendar = Calendar.fromJson(jsonDecode(
          response.body)); // Assuming Calendar has a fromJson() method
      devtools.log('Fetched calendar: $calendar');
      return calendar;
    } else {
      throw Exception('Failed to get calendar: ${response.reasonPhrase}');
    }
  }
}
