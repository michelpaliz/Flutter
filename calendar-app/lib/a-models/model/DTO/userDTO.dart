import 'package:first_project/a-models/model/group_data/event.dart';
import 'package:first_project/a-models/model/user_data/notification_user.dart';
import 'package:first_project/a-models/model/user_data/user.dart';

class UserDTO {
  final String id;
  final String authID;
  final String name;
  final String email;
  final String? photoUrl;
  final String userName;
  final List<String> groupIds;
  final List<Map<String, dynamic>>? events;
  final List<Map<String, dynamic>>? notifications;

  UserDTO({
    required this.id,
    required this.authID,
    required this.name,
    required this.email,
    required this.userName,
    required this.groupIds,
    this.photoUrl,
    this.events,
    this.notifications,
  });

  // Factory method to convert a User model to UserDTO
  factory UserDTO.fromUser(User user) {
    return UserDTO(
      id: user.id,
      authID: user.authId,
      name: user.name,
      email: user.email,
      userName: user.userName,
      photoUrl: user.photoUrl,
      groupIds: user.groupIds,
      events: user.events.map((event) => event.toMap()).toList(),
      notifications: user.notifications
          ?.map((notification) => notification.toJson())
          .toList(),
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authID': authID,
      'name': name,
      'email': email,
      'userName': userName,
      'photoUrl': photoUrl,
      'groupIds': groupIds,
      'events': events,
      'notifications': notifications,
    };
  }

  // Method to convert UserDTO to User
  User toUser() {
    return User(
      id: id,
      authID: authID,
      name: name,
      email: email,
      userName: userName,
      photoUrl: photoUrl,
      groupIds: groupIds,
      events: events!
          .map((event) => Event.fromJson(event))
          .toList(), // Convert EventDTO to Event
      notifications: notifications
          ?.map((notification) => NotificationUser.fromJson(notification))
          .toList(), // Assuming you have a fromJson for NotificationUser
    );
  }

  // Factory method to create a UserDTO from JSON
  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as String,
      authID: json['authID'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      userName: json['userName'] as String,
      photoUrl: json['photoUrl'] as String?,
      groupIds: (json['groupIds'] as List<dynamic>)
          .map((groupId) => groupId.toString())
          .toList(),
      events: (json['events'] as List<dynamic>?)
          ?.map((event) => event as Map<String, dynamic>)
          .toList(),
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((notification) => notification as Map<String, dynamic>)
          .toList(),
    );
  }
}
