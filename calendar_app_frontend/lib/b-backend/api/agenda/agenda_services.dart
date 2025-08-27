// agenda_services.dart
import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:http/http.dart' as http;

/// AgendaService talks to backend routes:
///   GET /api/agenda/me/upcoming?days=7&limit=100[&tz=Europe/Madrid]
///   GET /api/agenda/me/range?from=ISO&to=ISO[&tz=...]
///
/// It returns Event objects already sorted by startDate (server does it, but
/// we also sort client-side as a safety net).
class AgendaService {
  final String baseUrl = '${ApiConstants.baseUrl}/agenda';
  final http.Client _client;

  AgendaService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.loadToken();
    if (token == null) throw Exception("Authentication token not found");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  /// Fetch upcoming events for the current user.
  /// [days]: how many days ahead to look (default 14).
  /// [limit]: max items (default 200).
  /// [tz]: optional IANA timezone string; if null, backend default is used.
  Future<List<Event>> fetchUpcoming({
    int days = 14,
    int limit = 200,
    String? tz,
  }) async {
    final params = <String, String>{
      'days': days.toString(),
      'limit': limit.toString(),
      if (tz != null && tz.isNotEmpty) 'tz': tz,
    };

    final uri = Uri.parse('$baseUrl/me/upcoming').replace(queryParameters: params);
    final headers = await _authHeaders();

    devtools.log('📡 GET $uri');
    final res = await _client.get(uri, headers: headers);

    devtools.log('📥 ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load upcoming agenda: ${res.body}');
    }

    final List<dynamic> jsonList = jsonDecode(res.body);
    final events = jsonList.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();

    // Safety: sort by startDate asc if not already sorted
    events.sort((a, b) => a.startDate.compareTo(b.startDate));
    return events;
    }

  /// Fetch events for the current user within a [from, to] range (inclusive).
  /// Provide UTC ISO strings or local DateTimes; we send ISO-8601 UTC.
  /// [tz] optionally tells backend which timezone to use for server-side filtering.
  Future<List<Event>> fetchRange({
    required DateTime from,
    required DateTime to,
    String? tz,
    int? limit,
  }) async {
    if (!from.isBefore(to)) {
      throw ArgumentError('`from` must be strictly before `to`');
    }

    final params = <String, String>{
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
      if (tz != null && tz.isNotEmpty) 'tz': tz,
      if (limit != null) 'limit': limit.toString(),
    };

    final uri = Uri.parse('$baseUrl/me/range').replace(queryParameters: params);
    final headers = await _authHeaders();

    devtools.log('📡 GET $uri');
    final res = await _client.get(uri, headers: headers);

    devtools.log('📥 ${res.statusCode} ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load agenda range: ${res.body}');
    }

    final List<dynamic> jsonList = jsonDecode(res.body);
    final events = jsonList.map((e) => Event.fromJson(e as Map<String, dynamic>)).toList();

    events.sort((a, b) => a.startDate.compareTo(b.startDate));
    return events;
  }

  /// Convenience: fetch today + tomorrow window.
  Future<List<Event>> fetchTodayAndTomorrow({String? tz}) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day); // local midnight
    final end = start.add(const Duration(days: 2)); // end of tomorrow
    return fetchRange(from: start, to: end, tz: tz);
  }

  /// Dispose the internal client if you created this service without injecting a client.
  void dispose() {
    // Only call this if you *own* the client; if you inject a shared client,
    // don’t dispose it here.
    _client.close();
  }
}
