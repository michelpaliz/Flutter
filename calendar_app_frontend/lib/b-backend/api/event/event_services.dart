import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:calendar_app_frontend/b-backend/api/event/string_utils.dart';
import 'package:calendar_app_frontend/b-backend/api/recurrenceRule/recurrence_rule_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventService {
  final String baseUrl = 'http://192.168.1.16:3000/api/events';
  final RecurrenceRuleService _ruleService;

  Event? _event;
  Event? get event => _event;

  EventService({RecurrenceRuleService? ruleService})
      : _ruleService = ruleService ?? RecurrenceRuleService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.loadToken();
    if (token == null) throw Exception("Authentication token not found");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  /// Ensure the recurrence rule exists on the backend, replacing the rule with its ObjectId
  Future<Event> _ensureRuleId(Event ev) async {
    if (ev.recurrenceRule == null) return ev;

    final isObjectId = RegExp(r'^[a-f\d]{24}$').hasMatch(ev.recurrenceRule!.id);
    if (isObjectId) return ev;

    final created = await _ruleService.createRule(ev.recurrenceRule!);
    return ev.copyWith(recurrenceRule: created);
  }

  Future<Event> createEvent(Event eventData) async {
    try {
      //here we check if the recurrence is created or not
      final readyEvent = await _ensureRuleId(eventData);
      final headers = await _authHeaders();
      final body = jsonEncode(readyEvent.toBackendJson());

      devtools.log("📤 Sending event to $baseUrl");
      devtools.log("🧾 Headers: $headers");
      devtools.log("📝 Event body: $body");

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: body,
      );

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
    // final url = '$baseUrl/$eventId';
    final url = '$baseUrl/${baseId(eventId)}'; // ✅ strip suffix

    final headers = await _authHeaders();

    debugPrint("📡 GET $url");
    debugPrint("🔐 Headers: $headers");

    final response = await http.get(Uri.parse(url), headers: headers);

    debugPrint("📥 Status Code: ${response.statusCode}");
    debugPrint("📥 Response Body: ${response.body}");

    try {
      final decoded = jsonDecode(response.body);
      if (response.statusCode == 200) {
        debugPrint("✅ Decoded Event JSON: $decoded");
        return Event.fromJson(decoded);
      } else {
        throw Exception(
            '❌ Failed to fetch event – code: ${response.statusCode}, body: ${response.body}');
      }
    } catch (e) {
      debugPrint("❌ JSON parsing error or invalid event format: $e");
      rethrow;
    }
  }

  // Future<Event> updateEvent(
  //     String eventId, Map<String, dynamic> rawEventData) async {
  //   final event = await _ensureRuleId(Event.fromJson(rawEventData));
  //   final headers = await _authHeaders();
  //   final payload = jsonEncode(event.toBackendJson());

  //   debugPrint('📤 Sending payload: $payload');

  //   final response = await http.put(
  //     Uri.parse('$baseUrl/$eventId'),
  //     headers: headers,
  //     body: payload,
  //   );

  //   if (response.statusCode == 200) {
  //     return Event.fromJson(jsonDecode(response.body));
  //   } else {
  //     debugPrint('❌ Server responded: ${response.statusCode}');
  //     debugPrint('🧾 Body: ${response.body}');
  //     throw Exception('Failed to update event');
  //   }
  // }

  Future<Event> updateEvent(Event ev) async {
    final ready = await _ensureRuleId(ev);
    final headers = await _authHeaders();
    final payload = jsonEncode(ready.toBackendJson());

    final res = await http.put(
      // Uri.parse('$baseUrl/${ready.id.split('-').first}'),
      Uri.parse('$baseUrl/${baseId(ready.id)}'),
      headers: headers,
      body: payload,
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update event: ${res.body}');
    }
    return Event.fromJson(jsonDecode(res.body));
  }

  Future<void> deleteEvent(String eventId) async {
    final id = baseId(eventId); // ensures we strip suffix
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
      // Uri.parse('$baseUrl/$eventId'),
      Uri.parse('$baseUrl/${baseId(eventId)}'),

      headers: await _authHeaders(),
      body: jsonEncode({
        'isDone': isDone,
        'completedAt': isDone ? DateTime.now().toIso8601String() : null,
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
