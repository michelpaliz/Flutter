// user.dart

// ===== Helpers =====
import 'package:flutter/foundation.dart';

String requireString(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is String && v.isNotEmpty) return v;
  throw FormatException("Expected non-empty string for '$key', got: $v");
}

String requireStringAny(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v is String && v.isNotEmpty) return v;
  }
  throw FormatException(
      "Expected non-empty string for one of ${keys.join(', ')}, got: ${keys.map((k) => j[k]).toList()}");
}

String? optString(Map<String, dynamic> j, String key) {
  final v = j[key];
  return v is String ? v : null;
}

List<String> optStringList(Map<String, dynamic> j, String key) {
  final v = j[key];
  if (v is List) {
    return v.map((e) => e.toString()).toList();
  }
  return <String>[];
}

// Add this helper with your other helpers:
String? optStringAny(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v is String && v.isNotEmpty) return v;
  }
  return null;
}

Map<String, dynamic> unwrapUser(Map<String, dynamic> raw) {
  // Try common wrapper keys in order
  for (final key in ['user', 'data', 'profile', 'result']) {
    final v = raw[key];
    if (v is Map) return v.cast<String, dynamic>();
  }
  // If nothing matched, assume the whole object is the user
  return raw;
}

// ===== User class =====
class User {
  String _id;
  String _name;
  final String _email;
  String? _photoUrl;
  String? _photoBlobName;
  String _userName;
  List<String> _groupIds;
  List<String> _calendarsIds;
  List<String> _notificationsIds;

  User({
    required String id,
    required String name,
    required String email,
    required String userName,
    required List<String> groupIds,
    String? photoUrl,
    String? photoBlobName,
    List<String>? sharedCalendars,
    List<String>? notifications,
  })  : _id = id,
        _name = name,
        _email = email,
        _userName = userName,
        _groupIds = groupIds,
        _photoUrl = photoUrl,
        _photoBlobName = photoBlobName,
        _calendarsIds = sharedCalendars ?? [],
        _notificationsIds = notifications ?? [];

  // Getters & setters
  String get id => _id;
  String get name => _name;
  set name(String name) => _name = name;

  String get email => _email;

  List<String> get groupIds => _groupIds;
  set groupIds(List<String> groupIds) => _groupIds = groupIds;

  String? get photoUrl => _photoUrl;
  set photoUrl(String? photoUrl) => _photoUrl = photoUrl;

  String? get photoBlobName => _photoBlobName;
  set photoBlobName(String? blobName) => _photoBlobName = blobName;

  List<String> get sharedCalendars => _calendarsIds;
  set sharedCalendars(List<String>? sharedCalendars) =>
      _calendarsIds = sharedCalendars ?? [];

  List<String> get notifications => _notificationsIds;
  set notifications(List<String>? notifications) =>
      _notificationsIds = notifications ?? [];

  String get userName => _userName;
  set userName(String userName) => _userName = userName;

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'name': _name,
      'userName': _userName,
      'email': _email,
      'photoUrl': _photoUrl,
      'photoBlobName': _photoBlobName,
      'groupIds': _groupIds,
      'sharedCalendars': _calendarsIds,
      'notifications': _notificationsIds,
    };
  }

  // Create from JSON (SAFE)
  factory User.fromJson(Map<String, dynamic> raw, {String? fallbackId}) {
    final Map<String, dynamic> json = unwrapUser(raw);

    final id = optStringAny(json, ['id', '_id', 'userId']) ?? fallbackId;
    if (id == null || id.isEmpty) {
      throw FormatException(
          "Expected non-empty string for one of id/_id/userId, and no fallbackId was provided.");
    }

    return User(
      id: id,
      name: requireStringAny(json, ['name', 'fullName', 'displayName']),
      email: requireString(json, 'email'),
      userName: requireStringAny(json, ['userName', 'username']),
      groupIds: optStringList(json, 'groupIds'),
      photoUrl: optString(json, 'photoUrl'),
      photoBlobName: optString(json, 'photoBlobName'),
      sharedCalendars: optStringList(json, 'sharedCalendars'),
      notifications: optStringList(json, 'notifications'),
    );
  }

  // copyWith
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? photoBlobName,
    String? userName,
    List<String>? groupIds,
    List<String>? sharedCalendars,
    List<String>? notifications,
  }) {
    return User(
      id: id ?? _id,
      name: name ?? _name,
      email: email ?? _email,
      userName: userName ?? _userName,
      photoUrl: photoUrl ?? _photoUrl,
      photoBlobName: photoBlobName ?? _photoBlobName,
      groupIds: groupIds ?? _groupIds,
      sharedCalendars: sharedCalendars ?? _calendarsIds,
      notifications: notifications ?? _notificationsIds,
    );
  }

  // empty factory
  factory User.empty() {
    return User(
      id: '',
      name: '',
      email: '',
      userName: '',
      photoUrl: '',
      photoBlobName: '',
      groupIds: [],
      sharedCalendars: [],
      notifications: [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.userName == userName &&
        other.name == name &&
        // Lists: compare with listEquals from flutter/foundation.dart
        listEquals(other.groupIds, groupIds) &&
        listEquals(other.sharedCalendars, sharedCalendars) &&
        listEquals(other.notifications, notifications) &&
        other.photoUrl == photoUrl &&
        other.photoBlobName == photoBlobName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      userName,
      name,
      Object.hashAll(groupIds),
      Object.hashAll(sharedCalendars),
      Object.hashAll(notifications),
      photoUrl,
      photoBlobName,
    );
  }
}
