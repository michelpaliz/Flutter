import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:hexora/a-models/group_model/calendar/calendar.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/token_storage.dart';
import 'package:hexora/b-backend/blobUploader/blobServer.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:hexora/b-backend/core/group/api/group_api_client.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/models/Members_count.dart';
import 'package:http/http.dart' as http;

class GroupRepository {
  final GroupApiClient _groupService = GroupApiClient();

  /// 🟢 Load token helper
  Future<String> _getToken() async {
    final token = await TokenStorage.loadToken();
    if (token == null) throw Exception("Not authenticated");
    return token;
  }

  /// 🟢 Create a new group
  Future<Group> createGroup(Group group) async {
    final token = await _getToken();
    return await _groupService.createGroup(group, token);
  }

  /// 🟢 Get a single group by ID
  Future<Group> getGroupById(String groupId) async {
    final token = await _getToken();
    return await _groupService.getGroupById(groupId, token);
  }

  /// 🟢 Update a group
  Future<void> updateGroup(Group group) async {
    final token = await _getToken();
    final success = await _groupService.updateGroup(group, token);
    if (!success) {
      throw Exception("Failed to update group");
    }
  }

  /// 🟢 Delete a group
  Future<void> deleteGroup(String groupId) async {
    final token = await _getToken();
    await _groupService.deleteGroup(groupId, token);
  }

  /// 🟢 Get all groups by user
  Future<List<Group>> getGroupsByUser(String userName) async {
    final token = await _getToken();
    return await _groupService.getGroupsByUser(userName, token);
  }

  /// 🟢 Leave a group
  Future<void> leaveGroup(String userId, String groupId) async {
    final token = await _getToken();
    await _groupService.leaveGroup(userId, groupId, token);
  }

  /// 🟢 Respond to an invitation
  Future<void> respondToInvite({
    required String groupId,
    required String userId,
    required bool accepted,
  }) async {
    final token = await _getToken();
    await _groupService.respondToInvite(
      groupId: groupId,
      userId: userId,
      accepted: accepted,
      token: token,
    );
  }

  /// 🟢 Get member count
  Future<MembersCount> getMembersCount(String groupId, {String? mode}) async {
    final token = await _getToken();
    return await _groupService.getMembersCount(groupId, token, mode: mode);
  }

  /// 🟢 Fetch members metadata
  Future<Map<String, dynamic>> getGroupMembersMeta(String groupId) async {
    final token = await _getToken();
    return await _groupService.getGroupMembersMeta(groupId, token);
  }

  /// 🟢 Fetch member profiles
  Future<List<User>> getGroupMemberProfiles(String groupId,
      {List<String>? ids}) async {
    final token = await _getToken();
    final profiles =
        await _groupService.getGroupMemberProfiles(groupId, token, ids: ids);
    return profiles.map((p) => User.fromJson(p)).toList();
  }

  /// 🟢 Fetch calendar
  Future<Calendar> getCalendarById(String calendarId) async {
    final token = await _getToken();
    return await _groupService.getCalendarById(calendarId, token);
  }

  /// 🟢 Combined use case: Upload group photo and update backend record
  Future<void> uploadAndCommitGroupPhoto({
    required String groupId,
    required File file,
  }) async {
    final token = await _getToken();

    // Step 1: Upload to Azure Blob
    final uploadResult = await uploadImageToAzure(
      scope: 'groups',
      resourceId: groupId,
      file: file,
      accessToken: token,
    );

    // Step 2: Commit blob reference in backend
    final resp = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/groups/$groupId/photo'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'blobName': uploadResult.blobName}),
    );

    if (resp.statusCode != 200) {
      throw Exception('Failed to commit photo: ${resp.reasonPhrase}');
    }

    devtools.log('✅ Group photo updated for $groupId');
  }
}
