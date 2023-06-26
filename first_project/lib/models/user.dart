import 'package:first_project/models/event.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class User {
  String _name;
  final String _email;
  List<Event>? _events;
  String? _groupId; // Optional group ID field

  User(this._name, this._email, this._events, {String? groupId})
      : _groupId = groupId;

  String get name => _name;
  set name(String name) {
    _name = name;
  }

  String get email => _email;

  List<Event>? get events => _events;
  set events(List<Event>? events) {
    _events = events;
  }

  String? get groupId => _groupId;
  set groupId(String? groupId) {
    _groupId = groupId;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'email': _email,
      'events': _events?.map((event) => event.toMap()).toList(),
      'groupId': _groupId,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['name'],
      json['email'],
      (json['events'] as List<dynamic>?)
          ?.map((eventJson) => Event.fromJson(eventJson))
          .toList(),
      groupId: json['groupId'],
    );
  }

  factory User.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return User(
      firebaseUser.displayName ?? '',
      firebaseUser.email ?? '',
      null, // Set events to null or initialize it accordingly
      groupId: null, // Set groupId to null or initialize it accordingly
    );
  }
}
