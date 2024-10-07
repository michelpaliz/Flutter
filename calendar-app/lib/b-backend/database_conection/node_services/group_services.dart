import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/model/DTO/groupDTO.dart';
import 'package:first_project/a-models/model/group_data/calendar.dart';
import 'package:first_project/a-models/model/group_data/group.dart';
import 'package:http/http.dart' as http;

class GroupService {
  final String baseUrl =
      'http://192.168.1.16:3000/api/groups'; // Your server URL

  Future<bool> createGroup(Group group) async {
    devtools.log('Create group: ${group}');

    // Convert Group to GroupDTO before sending
    final GroupDTO groupDTO = GroupDTO.fromGroup(group);

    final response = await http.post(
      Uri.parse('$baseUrl'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(groupDTO.toJson()), // Send GroupDTO as JSON
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to create group: ${response.reasonPhrase}');
    }
  }

  Future<Group> getGroupById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      // Parse the response body into a GroupDTO and then convert it to Group
      final groupDTO = GroupDTO.fromJson(jsonDecode(response.body));
      Calendar calendar = await getCalendarById(groupDTO.calendarId);
      return groupDTO.toGroup(calendar);
    } else {
      throw Exception('Failed to get group: ${response.reasonPhrase}');
    }
  }

  Future<bool> updateGroup(Group group) async {
    // Convert Group to GroupDTO before sending
    final GroupDTO groupDTO = GroupDTO.fromGroup(group);

    final response = await http.put(
      Uri.parse('$baseUrl/${group.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(groupDTO.toJson()), // Send GroupDTO as JSON
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to update group: ${response.reasonPhrase}');
    }
  }

  Future<void> deleteGroup(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete group: ${response.reasonPhrase}');
    }
  }

  Future<List<Group>> getGroupsByUser(String userName) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userName'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);

      // Create a list of futures to fetch calendars for each group
      List<Future<Group>> groupFutures =
          body.map<Future<Group>>((dynamic item) async {
        final groupDTO = GroupDTO.fromJson(item);
        // Fetch calendar for the current group
        Calendar calendar = await getCalendarById(groupDTO.calendarId);
        return groupDTO.toGroup(calendar);
      }).toList();

      // Wait for all the futures to complete
      return await Future.wait(groupFutures);
    } else {
      throw Exception('Failed to load groups: ${response.reasonPhrase}');
    }
  }

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

  Future<Calendar> getCalendarById(String calendarId) async {
    final String calendarUrl =
        'http://192.168.1.16:3000/api/calendars/$calendarId'; // URL for calendar API

    final response = await http.get(Uri.parse(calendarUrl));

    if (response.statusCode == 200) {
      // Parse the response body into a Calendar
      final calendar = Calendar.fromJson(jsonDecode(response.body));
      devtools.log('Fetched calendar: $calendar');
      return calendar;
    } else {
      throw Exception('Failed to get calendar: ${response.reasonPhrase}');
    }
  }
}
