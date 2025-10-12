import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/model/event.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:hexora/b-backend/group_mng_flow/event/api/i_event_api_client.dart';
import 'package:hexora/b-backend/group_mng_flow/event/string_utils.dart';
import 'package:hexora/b-backend/group_mng_flow/recurrenceRule/recurrence_rule_api_client.dart';
import 'package:http/http.dart' as http;

class EventApiClient implements IEventApiClient {
  EventApiClient({
    http.Client? client,
    RecurrenceRuleApiClient? ruleService,
  })  : _client = client ?? http.Client(),
        _ruleService = ruleService ?? RecurrenceRuleApiClient();

  final http.Client _client;
  final RecurrenceRuleApiClient _ruleService;

  final String baseUrl = '${ApiConstants.baseUrl}/events';

  Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      };

  Future<Event> _ensureRuleId(Event ev, String token) async {
    if (ev.recurrenceRule == null) return ev;

    // Case-insensitive hex check for 24-char Mongo ObjectId
    final isObjectId = RegExp(r'^[a-f0-9]{24}$', caseSensitive: false)
        .hasMatch(ev.recurrenceRule!.id);
    if (isObjectId) return ev;

    final created = await _ruleService.createRule(ev.recurrenceRule!);
    return ev.copyWith(recurrenceRule: created);
  }

  @override
  Future<Event> createEvent(Event eventData, String token) async {
    try {
      final readyEvent = await _ensureRuleId(eventData, token);
      final headers = _authHeaders(token);
      final body = jsonEncode(readyEvent.toBackendJson());

      debugPrint('🌐 POST /events body: $body');

      devtools.log("📤 Sending event to $baseUrl");
      devtools.log("🧾 Headers: $headers");
      devtools.log("📝 Event body: $body");

      final res = await _client.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: body,
      );

      if (res.statusCode == 201) {
        return Event.fromJson(jsonDecode(res.body));
      }

      devtools.log("❌ Failed response: ${res.statusCode}");
      devtools.log("❌ Response body: ${res.body}");
      throw Exception('Failed to create event: ${res.body}');
    } catch (error) {
      devtools.log('[EXCEPTION] Create error: $error');
      rethrow;
    }
  }

  @override
  Future<Event> getEventById(String eventId, String token) async {
    final url = '$baseUrl/${baseId(eventId)}';
    final headers = _authHeaders(token);

    debugPrint("📡 GET $url");
    debugPrint("🔐 Headers: $headers");

    final res = await _client.get(Uri.parse(url), headers: headers);

    debugPrint("📥 Status Code: ${res.statusCode}");
    debugPrint("📥 Response Body: ${res.body}");

    if (res.statusCode == 200) {
      return Event.fromJson(jsonDecode(res.body));
    } else {
      throw Exception(
        '❌ Failed to fetch event – code: ${res.statusCode}, body: ${res.body}',
      );
    }
  }

  @override
  Future<Event> updateEvent(Event ev, String token) async {
    final ready = await _ensureRuleId(ev, token);
    final headers = _authHeaders(token);
    final payload = jsonEncode(ready.toBackendJson());

    final res = await _client.put(
      Uri.parse('$baseUrl/${baseId(ready.id)}'),
      headers: headers,
      body: payload,
    );

    if (res.statusCode != 200) {
      debugPrint('🔴 Update failed: ${res.statusCode}');
      debugPrint('📦 Payload sent: $payload');
      throw Exception('Failed to update event: ${res.body}');
    }

    return Event.fromJson(jsonDecode(res.body));
  }

  @override
  Future<void> deleteEvent(String eventId, String token) async {
    final id = baseId(eventId);
    final url = '$baseUrl/$id';

    debugPrint('🌐 [API] DELETE → $url');
    final headers = _authHeaders(token);
    debugPrint('🔐 [API] Headers: $headers');

    final res = await _client.delete(Uri.parse(url), headers: headers);

    debugPrint('📥 [API] Response Status: ${res.statusCode}');
    debugPrint('📥 [API] Response Body: ${res.body}');

    if (res.statusCode != 200) {
      debugPrint('❌ [API] Delete failed');
      throw Exception('Failed to delete event');
    }

    debugPrint('✅ [API] Event deleted: $id');
  }

  @override
  Future<Event> markEventAsDone(
    String eventId, {
    required bool isDone,
    required String token,
  }) async {
    final res = await _client.put(
      Uri.parse('$baseUrl/${baseId(eventId)}'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'isDone': isDone,
        'completedAt': isDone ? DateTime.now().toUtc().toIso8601String() : null,
      }),
    );

    if (res.statusCode == 200) {
      return Event.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to update event status');
    }
  }

  @override
  Future<List<Event>> getEventsByGroupId(String groupId, String token) async {
    final res = await _client.get(
      Uri.parse('$baseUrl/group/$groupId'),
      headers: _authHeaders(token),
    );

    if (res.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(res.body);
      return jsonList.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch events for group $groupId');
    }
  }
}
