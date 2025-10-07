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

// Returns first non-empty string among keys, else null
String? optStringAny(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v is String && v.isNotEmpty) return v;
  }
  return null;
}

Map<String, dynamic> unwrapUser(Map<String, dynamic> raw) {
  for (final key in ['user', 'data', 'profile', 'result']) {
    final v = raw[key];
    if (v is Map) return v.cast<String, dynamic>();
  }
  return raw;
}

// ===== User class =====
class User {
  String _id;
  String _name;                 // legal / full name
  String? _displayName;         // preferred display name
  final String _email;
  String _userName;             // unique handle/login

  String? _photoUrl;
  String? _photoBlobName;

  String? _bio;
  String? _phoneNumber;
  String? _location;

  List<String> _groupIds;
  List<String> _calendarsIds;
  List<String> _notificationsIds;

  User({
    required String id,
    required String name,
    required String email,
    required String userName,
    required List<String> groupIds,
    String? displayName,
    String? bio,
    String? phoneNumber,
    String? location,
    String? photoUrl,
    String? photoBlobName,
    List<String>? sharedCalendars,
    List<String>? notifications,
  })  : _id = id,
        _name = name,
        _displayName = displayName,
        _email = email,
        _userName = userName,
        _bio = bio,
        _phoneNumber = phoneNumber,
        _location = location,
        _groupIds = groupIds,
        _photoUrl = photoUrl,
        _photoBlobName = photoBlobName,
        _calendarsIds = sharedCalendars ?? [],
        _notificationsIds = notifications ?? [];

  // Getters & setters
  String get id => _id;

  String get name => _name;
  set name(String v) => _name = v;

  String? get displayName => _displayName;
  set displayName(String? v) => _displayName = v;

  String get email => _email;

  String get userName => _userName;
  set userName(String v) => _userName = v;

  String? get photoUrl => _photoUrl;
  set photoUrl(String? v) => _photoUrl = v;

  String? get photoBlobName => _photoBlobName;
  set photoBlobName(String? v) => _photoBlobName = v;

  String? get bio => _bio;
  set bio(String? v) => _bio = v;

  String? get phoneNumber => _phoneNumber;
  set phoneNumber(String? v) => _phoneNumber = v;

  String? get location => _location;
  set location(String? v) => _location = v;

  List<String> get groupIds => _groupIds;
  set groupIds(List<String> v) => _groupIds = v;

  List<String> get sharedCalendars => _calendarsIds;
  set sharedCalendars(List<String>? v) => _calendarsIds = v ?? [];

  List<String> get notifications => _notificationsIds;
  set notifications(List<String>? v) => _notificationsIds = v ?? [];

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'name': _name,
      'displayName': _displayName,
      'userName': _userName,
      'email': _email,
      'bio': _bio,
      'phoneNumber': _phoneNumber,
      'location': _location,
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

    // name: prefer 'name' / 'fullName' / 'displayName'
    final name = requireStringAny(json, ['name', 'fullName', 'displayName']);

    // displayName: true display field if present; else try name/userName
    final displayName =
        optStringAny(json, ['displayName']) ??
        optStringAny(json, ['name']) ??
        optStringAny(json, ['userName']);

    final email = requireString(json, 'email');

    final userName = requireStringAny(json, ['userName', 'username']);

    final bio = optStringAny(json, ['bio', 'about', 'description']);
    final phoneNumber = optStringAny(json, ['phoneNumber', 'phone']);
    final location = optStringAny(json, ['location', 'city']);

    return User(
      id: id,
      name: name,
      displayName: displayName,
      email: email,
      userName: userName,
      bio: bio,
      phoneNumber: phoneNumber,
      location: location,
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
    String? displayName,
    String? email,
    String? userName,
    String? bio,
    String? phoneNumber,
    String? location,
    String? photoUrl,
    String? photoBlobName,
    List<String>? groupIds,
    List<String>? sharedCalendars,
    List<String>? notifications,
  }) {
    return User(
      id: id ?? _id,
      name: name ?? _name,
      displayName: displayName ?? _displayName,
      email: email ?? _email,
      userName: userName ?? _userName,
      bio: bio ?? _bio,
      phoneNumber: phoneNumber ?? _phoneNumber,
      location: location ?? _location,
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
      displayName: '',
      email: '',
      userName: '',
      bio: '',
      phoneNumber: '',
      location: '',
      photoUrl: '',
      photoBlobName: '',
      groupIds: const [],
      sharedCalendars: const [],
      notifications: const [],
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
        other.displayName == displayName &&
        other.bio == bio &&
        other.phoneNumber == phoneNumber &&
        other.location == location &&
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
      displayName,
      bio,
      phoneNumber,
      location,
      Object.hashAll(groupIds),
      Object.hashAll(sharedCalendars),
      Object.hashAll(notifications),
      photoUrl,
      photoBlobName,
    );
  }
}
