// agenda_model.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';

/// A lightweight view-model for the Agenda.
class AgendaItem {
  final Event event;
  final Color color;         // derived from event.eventColorIndex
  final String? groupName;   // optional (if backend enriches)

  AgendaItem({
    required this.event,
    required this.color,
    this.groupName,
  });

  DateTime get startLocal => event.startDate.toLocal();
  DateTime get endLocal   => event.endDate.toLocal();
  String get title        => event.title;
  String? get groupId     => event.groupId;
}

/// Map eventColorIndex → color (swap to your palette if you have one).
Color agendaColorFromIndex(ThemeData theme, int idx) {
  const palette = <Color>[
    Colors.indigo, Colors.teal, Colors.deepPurple, Colors.orange,
    Colors.pink, Colors.blueGrey, Colors.cyan, Colors.green,
  ];
  if (idx >= 0 && idx < palette.length) return palette[idx];
  return theme.colorScheme.primary;
}

/// Repository contract for fetching events by IDs (from user.events).
abstract class AgendaRepository {
  Future<List<Event>> fetchEventsByIds({
    required List<String> ids,
    required String accessToken,
  });
}

/// HTTP implementation using POST bulk with chunking and a small GET fallback.
class ApiAgendaRepository implements AgendaRepository {
  final http.Client _client;
  ApiAgendaRepository(this._client);

  // Tune these if your backend has different limits.
  static const int _chunkSize = 100;

  @override
  Future<List<Event>> fetchEventsByIds({
    required List<String> ids,
    required String accessToken,
  }) async {
    if (ids.isEmpty) return [];

    // 1) De-duplicate while preserving original order
    final seen = <String>{};
    final deduped = <String>[];
    for (final id in ids) {
      if (id.isEmpty) continue;
      if (seen.add(id)) deduped.add(id);
    }
    if (deduped.isEmpty) return [];

    // 2) Batch POST in chunks
    final results = <Event>[];
    for (var i = 0; i < deduped.length; i += _chunkSize) {
      final chunk = deduped.sublist(i, min(i + _chunkSize, deduped.length));
      final events = await _fetchChunkPost(chunk, accessToken);
      results.addAll(events);
    }

    // 3) Optional: sort here; otherwise sort in the UI
    results.sort((a, b) => a.startDate.compareTo(b.startDate));
    return results;
  }

  Future<List<Event>> _fetchChunkPost(
    List<String> chunk,
    String accessToken,
  ) async {
    // Prefer a dedicated lookup route name like /events/lookup or /events/bulk-get
    final uri = Uri.parse('${ApiConstants.baseUrl}/events/bulk-get');

    final resp = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'ids': chunk}),
    );

    // If the server doesn't support this POST route (404/405), fall back to GET for small chunks.
    if (resp.statusCode == 404 || resp.statusCode == 405) {
      // GET fallback (works only for reasonably small chunks)
      final getUri = Uri.parse(
        '${ApiConstants.baseUrl}/events?ids=${chunk.map(Uri.encodeComponent).join(",")}',
      );
      final getResp = await _client.get(
        getUri,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      if (getResp.statusCode != 200) {
        throw Exception('Failed to fetch events (GET fallback): ${getResp.statusCode} ${getResp.body}');
      }
      return _parseEvents(getResp.body);
    }

    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch events: ${resp.statusCode} ${resp.body}');
    }
    return _parseEvents(resp.body);
  }

  List<Event> _parseEvents(String body) {
    final data = jsonDecode(body);
    final List list = (data is List) ? data : (data['events'] ?? data['data'] ?? []);
    return list
        .map((e) => Event.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }
}

/// Convert raw Events → AgendaItems (colors via eventColorIndex).
List<AgendaItem> buildAgendaItems(List<Event> events, ThemeData theme) {
  return events.map((ev) {
    final color = agendaColorFromIndex(theme, ev.eventColorIndex);
    return AgendaItem(event: ev, color: color, groupName: null);
  }).toList();
}
