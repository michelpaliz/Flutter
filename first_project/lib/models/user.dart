import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:first_project/models/event.dart';

class User {
  String _id;
  String _name;
  final String _email;
  String? _photoUrl;
  List<Event>? _events;
  List<String>? _groupIds; // List of group IDs

  User(this._id, this._name, this._email, this._events,
      {List<String>? groupIds, String? photoUrl})
      : _groupIds = groupIds,
        _photoUrl = photoUrl;

  String get id => _id;

  String get name => _name;
  set name(String name) {
    _name = name;
  }

  String get email => _email;

  List<Event>? get events => _events;
  set events(List<Event>? events) {
    _events = events;
  }

  List<String>? get groupIds => _groupIds;
  set groupIds(List<String>? groupIds) {
    _groupIds = groupIds;
  }

  get photoUrl => _photoUrl;
  set photoUrl(photoUrl) {
    _photoUrl = photoUrl;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'email': _email,
      'photoUrl': _photoUrl,
      'events': _events?.map((event) => event.toMap()).toList(),
      'groupIds':
          _groupIds, // Save the list of group IDs in the JSON representation
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      json['id'],
      json['name'],
      json['email'],
      (json['events'] as List<dynamic>?)
          ?.map((eventJson) => Event.fromJson(eventJson))
          .toList(),
      groupIds: json['groupIds'] != null
          ? List<String>.from(
              json['groupIds']) // Parse groupIds as a list of strings
          : null,
      photoUrl: json['photoUrl'],
    );
  }

  static Future<User> getUserByEmail(String email) async {
    final firestore = FirebaseFirestore.instance;

    // Fetch the user document from Firestore using the email
    final userSnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      // User document found, retrieve the user data
      final userDocument = userSnapshot.docs.first;
      final userData = userDocument.data();

      // Create the User instance
      return User(
        userDocument.id,
        userData['name'] ?? '',
        email,
        (userData['events'] as List<dynamic>?)
            ?.map((eventJson) => Event.fromJson(eventJson))
            .toList(),
        groupIds: userData[
            'groupIds'], // Initialize groupIds based on fetched user data
      );
    } else {
      // User document not found, return a default User instance
      return User(
        '',
        '',
        email,
        [], // Set events to an empty list or initialize it accordingly
        groupIds: null, // Set groupIds to null or initialize it accordingly
      );
    }
  }

  static Future<User> fromFirebaseUser(firebase_auth.User firebaseUser) {
    return getUserByEmail(firebaseUser.email!);
  }
}
