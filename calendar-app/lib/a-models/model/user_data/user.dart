import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:first_project/a-models/model/DTO/userDTO.dart';
import 'package:first_project/a-models/model/group_data/event.dart';
import 'package:first_project/a-models/model/user_data/notification_user.dart';

class User {
  String _id;
  String _authID;
  String _name;
  final String _email;
  String? _photoUrl;
  String _userName;
  List<Event> _events;
  List<String> _groupIds;
  List<NotificationUser>? _notifications;

  User({
    required String id,
    required String authID,
    required String name,
    required String email,
    required String userName, // Include userName in the constructor
    required List<Event> events,
    required List<String> groupIds,
    String? photoUrl,
    List<NotificationUser>? notifications,
  })  : _id = id,
        _name = name,
        _authID = authID,
        _email = email,
        _userName = userName, // Initialize _userName
        _events = events,
        _groupIds = groupIds,
        _photoUrl = photoUrl,
        _notifications = notifications;

  String get id => _id;

  String get authId => _authID;

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

  String get userName => _userName; // Include getter for userName
  set userName(String userName) {
    _userName = userName; // Include setter for userName
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'authID': _authID,
      'userName': _userName,
      'email': _email,
      'photoUrl': _photoUrl,
      'events': _events.map((event) => event.toMap()).toList(),
      'groupIds': _groupIds,
      'notifications':
          _notifications?.map((notification) => notification.toJson()).toList
    };
  }

  //   Map<String, dynamic> toJson() {
  //   return {
  //     'id': _id,
  //     'name': _name,
  //     'authID': _authID,
  //     'userName': _userName,
  //     'email': _email,
  //     'photoUrl': _photoUrl,
  //     'events': _events.map((event) => event.toMap()).toList(),
  //     'groupIds': _groupIds,
  //     'notifications': _notifications
  //         ?.map((notification) => notification.toJson())
  //         .toList()
  //       ?..sort((a, b) =>
  //           b['_timestamp'].compareTo(a['_timestamp'])), // Sort by timestamp
  //     'hasNewNotifications': hasNewNotifications,
  //   };
  // }

  // Factory method to create a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      authID: json['authID'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      userName: json['userName'] as String,
      events: (json['events'] as List<dynamic>?)!
          .map((eventJson) => Event.fromJson(eventJson))
          .toList(),
      //       events: (json['events'] as List<dynamic>?)!
      // .map((eventJson) => Event.fromJson(jsonDecode(eventJson)))
      // .toList(),
      groupIds: (json['groupIds'] as List<dynamic>?)!
          .map((groupId) => groupId.toString())
          .toList(),
      photoUrl: json['photoUrl'] as String?,
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map(
              (notificationUser) => NotificationUser.fromJson(notificationUser))
          .toList(),
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

      return User(
        id: userDocument.id,
        name: userData['name'],
        authID: userData['authID'],
        email: email,
        userName: userData['userName'],
        events: (userData['events'] as List<dynamic>?)!
            .map((eventJson) => Event.fromJson(eventJson))
            .toList(),
        groupIds: groupIds,
        notifications: notifications,
      );
    } else {
      return User(
        id: '',
        authID: '',
        name: '',
        email: email,
        userName: '',
        events: [],
        groupIds: [],
        notifications: [],
      );
    }
  }

  static Future<User> fromFirebaseUser(firebase_auth.User firebaseUser) {
    return getUserByEmail(firebaseUser.email!);
  }

  static User fromDTO(UserDTO dto) {
    return User(
        id: dto.id,
        authID: dto.authID,
        name: dto.name,
        email: dto.email,
        userName: dto.userName,
        events: (dto.events ?? [])
            .map((eventMap) => Event.fromJson(eventMap))
            .toList(),
        groupIds: dto.groupIds,
        photoUrl: dto.photoUrl,
        notifications: (dto.notifications ?? [])
            .map(
                (notificationMap) => NotificationUser.fromJson(notificationMap))
            .toList());
  }

  UserDTO toDTO() {
    return UserDTO(
      id: _id,
      authID: _authID,
      name: _name,
      email: _email,
      userName: _userName,
      events: _events.map((event) => event.toMap()).toList(),
      groupIds: _groupIds,
      photoUrl: _photoUrl,
      notifications:
          _notifications?.map((notification) => notification.toJson()).toList(),
    );
  }

  static createDefaultUser() {
    return User(
      id: 'default_id',
      authID: 'default_auth_id',
      name: 'Default User Name',
      email: 'default@example.com',
      userName: 'default_username', // Default user name
      events: [], // Empty list for events
      groupIds: [], // Empty list for group IDs
      photoUrl: 'default_photo_url', // Default photo URL or null
      notifications: [], // Empty list for notifications
    );
  }

  @override
  String toString() {
    return 'User('
        'id: $_id, '
        'name: $_name, '
        'authID: $_authID, '
        'email: $_email, '
        'userName: $_userName, ' // Include this line
        'photoUrl: $_photoUrl, '
        'events: $_events, '
        'groupIds: $_groupIds, '
        'notifications: $_notifications, ';
  }
}
