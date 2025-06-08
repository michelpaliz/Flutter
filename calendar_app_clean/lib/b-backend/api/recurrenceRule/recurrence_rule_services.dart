import 'dart:convert';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:http/http.dart' as http;

class RecurrenceRuleService {
  final String _baseUrl = 'http://192.168.1.16:3000/api/recurrence-rules';

  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.loadToken();
    if (token == null) throw Exception("Authentication token not found");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  /// Create a new recurrence rule
  Future<RecurrenceRule> createRule(RecurrenceRule rule) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: await _authHeaders(),
      body: jsonEncode(rule.toJson()),
    );

    devtools.log('🔁 POST /recurrence-rules → ${response.statusCode}');
    devtools.log('📦 Payload: ${rule.toJson()}');

    if (response.statusCode == 201) {
      return RecurrenceRule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create recurrence rule: ${response.body}');
    }
  }

  /// Get all recurrence rules (optional, useful for admin/debug)
  Future<List<RecurrenceRule>> getAllRules() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => RecurrenceRule.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch recurrence rules');
    }
  }

  /// Get a rule by ID (if needed)
  Future<RecurrenceRule> getRuleById(String id) async {
    final url = '$_baseUrl/$id';
    final response = await http.get(
      Uri.parse(url),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      return RecurrenceRule.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Failed to get recurrence rule: ${response.reasonPhrase}');
    }
  }
}
