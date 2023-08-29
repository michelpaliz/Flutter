import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:first_project/models/event.dart';
import 'package:first_project/models/notification_user.dart';

class User {
  String _id;
  String _name;
  final String _email;
  String? _photoUrl;
  List<Event> _events;
  List<String> _groupIds;
  List<NotificationUser>? _notifications;
  bool hasNewNotifications;

  User({
    required String id,
    required String name,
    required String email,
    required List<Event> events,
    required List<String> groupIds,
    String? photoUrl,
    List<NotificationUser>? notifications,
    this.hasNewNotifications = false,
  })  : _id = id,
        _name = name,
        _email = email,
        _events = events,
        _groupIds = groupIds,
        _photoUrl = photoUrl,
        _notifications = notifications;

  String get id => _id;

  String get name => _name;
  set name(String name) {
    _name = name;
  }

  String get email => _email;

  List<Event> get events => _events;
  set events(List<Event> events) {
    _events = events;
  }

  List<String> get groupIds => _groupIds;
  set groupIds(List<String> groupIds) {
    _groupIds = groupIds;
  }

  get photoUrl => _photoUrl;
  set photoUrl(photoUrl) {
    _photoUrl = photoUrl;
  }

  get notifications => _notifications;
  set notifications(notifications) {
    _notifications = notifications;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'email': _email,
      'photoUrl': _photoUrl,
      'events': _events.map((event) => event.toMap()).toList(),
      'groupIds': _groupIds,
      'notifications':
          _notifications?.map((notification) => notification.toJson()).toList(),
      'hasNewNotifications': hasNewNotifications, // Include the field
    };
  }

  // Factory method to create a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      events: (json['events'] as List<dynamic>?)!
          .map((eventJson) => Event.fromJson(eventJson))
          .toList(),
      groupIds: (json['groupIds'] as List<dynamic>?)!
          .map((groupId) => groupId.toString())
          .toList(),
      photoUrl: json['photoUrl'] as String?,
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map(
              (notificationUser) => NotificationUser.fromJson(notificationUser))
          .toList(),
      hasNewNotifications:
          json['hasNewNotifications'] as bool, // Include this line
    );
  }

  static Future<User> getUserByEmail(String email) async {
    final firestore = FirebaseFirestore.instance;

    final userSnapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userDocument = userSnapshot.docs.first;
      final userData = userDocument.data();

      final groupIds = (userData['groupIds'] as List<dynamic>)
          .map((dynamic id) => id.toString())
          .toList();

      final notifications = (userData['notifications'] as List<dynamic>?)
          ?.map(
              (notificationJson) => NotificationUser.fromJson(notificationJson))
          .toList();

      final hasNewNotifications =
          userData['hasNewNotifications'] as bool; // Add this line

      return User(
        id: userDocument.id,
        name: userData['name'] ?? '',
        email: email,
        events: (userData['events'] as List<dynamic>?)!
            .map((eventJson) => Event.fromJson(eventJson))
            .toList(),
        groupIds: groupIds,
        notifications: notifications,
        hasNewNotifications: hasNewNotifications, // Add this line
      );
    } else {
      return User(
        id: '',
        name: '',
        email: email,
        events: [],
        groupIds: [],
        notifications: [],
        hasNewNotifications: false, // Set default value
      );
    }
  }

  static Future<User> fromFirebaseUser(firebase_auth.User firebaseUser) {
    return getUserByEmail(firebaseUser.email!);
  }

  @override
  String toString() {
    return 'User('
        'id: $_id, '
        'name: $_name, '
        'email: $_email, '
        'photoUrl: $_photoUrl, '
        'events: $_events, '
        'groupIds: $_groupIds, '
        'notifications: $_notifications, '
        'hasNewNotifications: $hasNewNotifications' // Updated line
        ')';
  }
}
