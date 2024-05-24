import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/group.dart';
import 'package:http/http.dart' as http;

class GroupService {
  final String baseUrl =
      'http://192.168.1.16:3000/api'; // Update with your server URL

  Future<Group> createGroup(Group group) async {
    devtools.log('Create group ${group}');
    final response = await http.post(
      Uri.parse('$baseUrl/groups'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(group.toJson()),
    );

    if (response.statusCode == 201) {
      return Group.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create group: ${response.reasonPhrase}');
    }
  }

  Future<Group> getGroupById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/groups/$id'));

    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load group: ${response.reasonPhrase}');
    }
  }

  Future<Group> updateGroup(String id, Group group) async {
    final response = await http.put(
      Uri.parse('$baseUrl/groups/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(group.toJson()),
    );

    if (response.statusCode == 200) {
      return Group.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update group: ${response.reasonPhrase}');
    }
  }

  Future<void> deleteGroup(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/groups/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete group: ${response.reasonPhrase}');
    }
  }

  Future<List<Group>> getGroupsByUser(String userName) async {
    final response = await http.get(Uri.parse('$baseUrl/groups/user/$userName'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Group.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load groups: ${response.reasonPhrase}');
    }
  }
}
