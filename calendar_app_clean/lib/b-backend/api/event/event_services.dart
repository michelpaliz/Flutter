import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:http/http.dart' as http;

class EventService {
  final String baseUrl = 'http://192.168.1.16:3000/api/events';

  Event? _event;
  Event? get event => _event;

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.loadToken();
    if (token == null) throw Exception("Authentication token not found");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  Future<bool> createEvent(Event eventData) async {
    try {
      devtools.log('[CREATE] Event data: ${eventData.toMap()}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _authHeaders(),
        body: jsonEncode(eventData.toMap()),
      );

      if (response.statusCode == 201) {
        _event = Event.fromJson(jsonDecode(response.body));
        devtools.log('[SUCCESS] Event created: $_event');
        return true;
      } else {
        devtools.log('[ERROR] Create failed: ${response.body}');
        return false;
      }
    } catch (error) {
      devtools.log('[EXCEPTION] Create error: $error');
      throw Exception('An error occurred while creating the event.');
    }
  }

  Future<Event> getEventById(String eventId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$eventId'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch event');
    }
  }

  Future<Event> updateEvent(String eventId, Event eventData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$eventId'),
      headers: await _authHeaders(),
      body: jsonEncode(eventData.toMap()),
    );

    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$eventId'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }

  Future<Event> markEventAsDone(String eventId, {required bool isDone}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$eventId'),
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
}
