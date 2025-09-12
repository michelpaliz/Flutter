import 'dart:convert';
import 'package:calendar_app_frontend/a-models/group_model/service/service.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/token_storage.dart';
import 'package:calendar_app_frontend/b-backend/api/config/api_constants.dart';
import 'package:http/http.dart' as http;

class ServicesApi {
  final String _base = '${ApiConstants.baseUrl}/services';

  Future<Map<String, String>> _headers() async => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${await TokenStorage.loadToken()}',
      };

  Uri _u([String path = '', Map<String, String?> q = const {}]) {
    final filtered = Map.fromEntries(
      q.entries.where((e) => e.value != null && e.value!.isNotEmpty),
    );
    return Uri.parse('$_base$path').replace(queryParameters: filtered.isEmpty ? null : filtered);
  }

  T _decode<T>(http.Response r, T Function(dynamic) map) {
    if (r.statusCode >= 200 && r.statusCode < 300) {
      final body = r.body.isEmpty ? null : jsonDecode(r.body);
      return map(body);
    }
    String msg;
    try {
      final j = jsonDecode(r.body);
      msg = j is Map && j['message'] is String ? j['message'] : r.reasonPhrase ?? 'Request failed';
    } catch (_) {
      msg = r.reasonPhrase ?? 'Request failed';
    }
    throw Exception(msg);
  }

  // GET /services?groupId=...&active=true|false
  Future<List<Service>> list({String? groupId, bool? active}) async {
    final r = await http.get(_u('', {
      'groupId': groupId,
      if (active != null) 'active': active.toString(),
    }), headers: await _headers());

    return _decode<List<Service>>(r, (j) {
      if (j is! List) throw Exception('Unexpected services payload');
      return j.map<Service>((e) => Service.fromJson(e)).toList();
    });
  }

  // POST /services
  Future<Service> create(Service service) async {
    final r = await http.post(
      _u(),
      headers: await _headers(),
      body: jsonEncode(service.toJson()),
    );
    return _decode<Service>(r, (j) => Service.fromJson(j));
  }

  // GET /services/:id
  Future<Service> getById(String id) async {
    final r = await http.get(_u('/$id'), headers: await _headers());
    return _decode<Service>(r, (j) => Service.fromJson(j));
  }

  // PATCH /services/:id  (full update)
  Future<Service> update(Service service) async {
    if (service.id.isEmpty) throw Exception('Service.id is required');
    final r = await http.patch(
      _u('/${service.id}'),
      headers: await _headers(),
      body: jsonEncode(service.toJson()),
    );
    return _decode<Service>(r, (j) => Service.fromJson(j));
  }

  // PATCH /services/:id  (partial fields)
  Future<Service> updateFields(String id, Map<String, dynamic> fields) async {
    final r = await http.patch(
      _u('/$id'),
      headers: await _headers(),
      body: jsonEncode(fields),
    );
    return _decode<Service>(r, (j) => Service.fromJson(j));
  }

  // PATCH /services/:id/active  { isActive: true|false }
  Future<Service> setActive(String id, bool isActive) async {
    final r = await http.patch(
      _u('/$id/active'),
      headers: await _headers(),
      body: jsonEncode({'isActive': isActive}),
    );
    return _decode<Service>(r, (j) => Service.fromJson(j));
  }
}
