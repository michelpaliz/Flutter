// event_services.dart
import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/token_storage.dart';
import 'package:hexora/b-backend/config/api_constants.dart';
import 'package:hexora/b-backend/core/event/string_utils.dart';
import 'package:hexora/b-backend/core/recurrenceRule/recurrence_rule_api_client.dart';
import 'package:http/http.dart' as http;

class EventApiClient {
  final String baseUrl = '${ApiConstants.baseUrl}/events';
  final RecurrenceRuleApiClient _ruleService;

  Event? _event;
  Event? get event => _event;

  EventApiClient({RecurrenceRuleApiClient? ruleService})
      : _ruleService = ruleService ?? RecurrenceRuleApiClient();

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.loadToken();
    if (token == null) throw Exception("Authentication token not found");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<Event> _ensureRuleId(Event ev) async {
    if (ev.recurrenceRule == null) return ev;

    // Case-insensitive hex check for 24-char Mongo ObjectId
    final isObjectId = RegExp(r'^[a-f0-9]{24}$', caseSensitive: false)
        .hasMatch(ev.recurrenceRule!.id);
    if (isObjectId) return ev;

    final created = await _ruleService.createRule(ev.recurrenceRule!);
    return ev.copyWith(recurrenceRule: created);
  }

  Future<Event> createEvent(Event eventData) async {
    try {
      final readyEvent = await _ensureRuleId(eventData);
      final headers = await _authHeaders();
      final body = jsonEncode(readyEvent.toBackendJson());

      debugPrint('🌐 POST /events body: $body'); // must match #0

      devtools.log("📤 Sending event to $baseUrl");
      devtools.log("🧾 Headers: $headers");
      devtools.log("📝 Event body: $body");

      final response =
          await http.post(Uri.parse(baseUrl), headers: headers, body: body);

      if (response.statusCode == 201) {
        _event = Event.fromJson(jsonDecode(response.body));
        return _event!;
      }

      devtools.log("❌ Failed response: ${response.statusCode}");
      devtools.log("❌ Response body: ${response.body}");
      throw Exception('Failed to create event: ${response.body}');
    } catch (error) {
      devtools.log('[EXCEPTION] Create error: $error');
      rethrow;
    }
  }

  Future<Event> getEventById(String eventId) async {
    final url = '$baseUrl/${baseId(eventId)}';
    final headers = await _authHeaders();

    debugPrint("📡 GET $url");
    debugPrint("🔐 Headers: $headers");

    final response = await http.get(Uri.parse(url), headers: headers);

    debugPrint("📥 Status Code: ${response.statusCode}");
    debugPrint("📥 Response Body: ${response.body}");

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200) {
      debugPrint("✅ Decoded Event JSON: $decoded");
      return Event.fromJson(decoded);
    } else {
      throw Exception(
          '❌ Failed to fetch event – code: ${response.statusCode}, body: ${response.body}');
    }
  }

  Future<Event> updateEvent(Event ev) async {
    final ready = await _ensureRuleId(ev);
    final headers = await _authHeaders();
    final payload = jsonEncode(ready.toBackendJson());

    final res = await http.put(
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

  Future<void> deleteEvent(String eventId) async {
    final id = baseId(eventId);
    final url = '$baseUrl/$id';

    debugPrint('🌐 [API] DELETE → $url');

    final headers = await _authHeaders();
    debugPrint('🔐 [API] Headers: $headers');

    final response = await http.delete(Uri.parse(url), headers: headers);

    debugPrint('📥 [API] Response Status: ${response.statusCode}');
    debugPrint('📥 [API] Response Body: ${response.body}');

    if (response.statusCode != 200) {
      debugPrint('❌ [API] Delete failed');
      throw Exception('Failed to delete event');
    }

    debugPrint('✅ [API] Event deleted: $id');
  }

  Future<Event> markEventAsDone(String eventId, {required bool isDone}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${baseId(eventId)}'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'isDone': isDone,
        'completedAt': isDone ? DateTime.now().toUtc().toIso8601String() : null,
      }),
    );

    if (response.statusCode == 200) {
      final updatedEvent = Event.fromJson(jsonDecode(response.body));
      _event = updatedEvent;
      return updatedEvent;
    } else {
      throw Exception('Failed to update event status');
    }
  }

  Future<List<Event>> getEventsByGroupId(String groupId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/group/$groupId'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch events for group $groupId');
    }
  }
}
