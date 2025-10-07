import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:hexora/a-models/group_model/calendar/calendar.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:hexora/b-backend/core/group/error_classes/error_classes.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/Members_count.dart';
import 'package:http/http.dart' as http;

class GroupApiClient {
  final String baseUrl = '${ApiConstants.baseUrl}/groups';

  /// Generic header builder (token provided from Repository)
  Map<String, String> authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };

  /// Create group
  Future<Group> createGroup(Group group, String token) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: authHeaders(token),
      body: jsonEncode(group.toJsonForCreation()),
    );

    if (response.statusCode == 201) {
      return Group.fromJson(jsonDecode(response.body));
    } else {
      throw HttpFailure(response.statusCode, response.body);
    }
  }

  /// Get group by ID
  Future<Group> getGroupById(String id, String token) async {
    final res =
        await http.get(Uri.parse('$baseUrl/$id'), headers: authHeaders(token));

    devtools.log('📥 GET /groups/$id → ${res.statusCode}');
    devtools.log('📦 Body: ${res.body}');

    if (res.statusCode == 200 && res.body != 'null') {
      return Group.fromJson(jsonDecode(res.body));
    }
    if (res.statusCode == 404) throw NotFoundException('Group $id not found');
    throw HttpFailure(res.statusCode, res.body);
  }

  /// Update group
  Future<bool> updateGroup(Group group, String token) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${group.id}'),
      headers: authHeaders(token),
      body: jsonEncode(group.toJson()),
    );
    return response.statusCode == 200;
  }

  /// Delete group
  Future<void> deleteGroup(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: authHeaders(token),
    );
    if (response.statusCode != 200) {
      throw HttpFailure(response.statusCode, response.body);
    }
  }

  /// Leave group
  Future<void> leaveGroup(String userId, String groupId, String token) async {
    final url = Uri.parse('$baseUrl/$groupId/users/$userId');
    final response = await http.delete(url, headers: authHeaders(token));
    if (response.statusCode != 200) {
      throw HttpFailure(response.statusCode, response.body);
    }
  }

  /// Get groups for a user (basic)
  Future<List<Group>> getGroupsByUser(String userName, String token) async {
    final res = await http.get(Uri.parse('$baseUrl/user/$userName'),
        headers: authHeaders(token));
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as List<dynamic>;
      return body.map((json) => Group.fromJson(json)).toList();
    }
    throw HttpFailure(res.statusCode, res.body);
  }

  /// Respond to group invite
  Future<void> respondToInvite({
    required String groupId,
    required String userId,
    required bool accepted,
    required String token,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/invite/response'),
      headers: authHeaders(token),
      body: jsonEncode(
          {'groupId': groupId, 'userId': userId, 'accepted': accepted}),
    );

    devtools.log('📤 PUT /invite/response → ${res.statusCode}');
    if (res.statusCode != 200) {
      throw HttpFailure(res.statusCode, res.body);
    }
  }

  /// Get members count
  Future<MembersCount> getMembersCount(String groupId, String token,
      {String? mode}) async {
    final query = mode == null ? '' : '?mode=$mode';
    final res = await http.get(
        Uri.parse('$baseUrl/$groupId/members/count$query'),
        headers: authHeaders(token));

    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      return MembersCount.fromJson(json);
    }
    if (res.statusCode == 404)
      throw NotFoundException('Group $groupId not found');
    throw HttpFailure(res.statusCode, res.body);
  }

  /// Get group members metadata
  Future<Map<String, dynamic>> getGroupMembersMeta(
      String groupId, String token) async {
    final res = await http.get(Uri.parse('$baseUrl/$groupId/members'),
        headers: authHeaders(token));

    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 404)
      throw NotFoundException('Group $groupId not found');
    throw HttpFailure(res.statusCode, res.body);
  }

  /// Get member profiles
  Future<List<Map<String, dynamic>>> getGroupMemberProfiles(
    String groupId,
    String token, {
    List<String>? ids,
  }) async {
    final body = ids == null ? {} : {'ids': ids};
    final res = await http.post(
      Uri.parse('$baseUrl/$groupId/members/profiles'),
      headers: authHeaders(token),
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      return List<Map<String, dynamic>>.from(decoded);
    }

    if (res.statusCode == 404)
      throw NotFoundException('Group $groupId not found');
    throw HttpFailure(res.statusCode, res.body);
  }

  /// Get calendar by ID
  Future<Calendar> getCalendarById(String calendarId, String token) async {
    final url = '${ApiConstants.baseUrl}/calendars/$calendarId';
    final res = await http.get(Uri.parse(url), headers: authHeaders(token));

    if (res.statusCode == 200) {
      return Calendar.fromJson(jsonDecode(res.body));
    } else {
      throw HttpFailure(res.statusCode, res.body);
    }
  }
}
