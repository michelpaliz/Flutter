import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';

import 'calendar.dart';

class Group {
  final String id;
  String groupName;
  final String ownerId; // ID of the group owner
  final Map<String, String> userRoles; // Map of user IDs to their roles
  final Calendar calendar; // Shared calendar for the group
  List<User> users;
  final DateTime createdTime; // Time the group was created
  bool
      repetitiveEvents; // With this variable, I can check if the members want to have repetitive events at the same time.
  String description; // A description of the group
  String photo; // Add the new field for storing a photo link
  Map<String, UserInviteStatus>?
      invitedUsers; // New field to store invited users and their answers

  Group({
    required this.id,
    required this.groupName,
    required this.ownerId,
    required this.userRoles,
    required this.calendar,
    required this.users,
    required this.createdTime,
    this.repetitiveEvents = false,
    required this.description,
    required this.photo,
    Map<String, UserInviteStatus>?
        invitedUsers, // Change the type to Map<String, Invitation>?
  }) : invitedUsers = invitedUsers ?? {};

  Group copyWith({
    bool? repetitiveEvents,
    DateTime? createdTime,
    String? description,
    String? photo,
    Map<String, UserInviteStatus>? invitedUsers,
  }) {
    return Group(
      id: this.id,
      groupName: this.groupName,
      ownerId: this.ownerId,
      userRoles: this.userRoles,
      calendar: this.calendar,
      users: this.users,
      createdTime: createdTime ?? this.createdTime,
      repetitiveEvents: repetitiveEvents ?? this.repetitiveEvents,
      description: description ?? this.description,
      photo: photo ?? this.photo,
      invitedUsers: invitedUsers ?? this.invitedUsers,
    );
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    List<dynamic>? usersJson = json['users'];
    List<User> users = usersJson != null
        ? usersJson.map((userJson) => User.fromJson(userJson)).toList()
        : [];

    Map<String, dynamic>? invitedUsersJson = json['invitedUsers'];
    Map<String, UserInviteStatus>? invitedUsers = invitedUsersJson != null
        ? invitedUsersJson.map(
            (key, value) => MapEntry(key, UserInviteStatus.fromJson(value)))
        : null;

    return Group(
      id: json['id'] ?? '',
      groupName: json['groupName'] ?? '',
      ownerId: json['ownerId'] ?? '',
      userRoles: Map<String, String>.from(json['userRoles'] ?? {}),
      calendar: Calendar.fromJson(json['calendar'] ?? {}),
      users: users,
      createdTime: json['createdTime'] != null
          ? DateTime.parse(json['createdTime'])
          : DateTime.now(),
      repetitiveEvents: json['repetitiveEvents'] ?? false,
      description: json['description'] ?? '',
      photo: json['photo'] ?? '', // Parse the new field here
      invitedUsers: invitedUsers,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> usersJson =
        users.map((user) => user.toJson()).toList();

    Map<String, dynamic>? invitedUsersJson;
    if (invitedUsers != null) {
      invitedUsersJson = {};
      invitedUsers!.forEach((key, value) {
        invitedUsersJson![key] = value.toJson();
      });
    }

    return {
      'id': id,
      'groupName': groupName,
      'ownerId': ownerId,
      'userRoles': userRoles,
      'calendar': calendar.toJson(),
      'users': usersJson,
      'createdTime': createdTime.toIso8601String(),
      'repetitiveEvents': repetitiveEvents,
      'description': description,
      'photo': photo, // Include the new field here
      'invitedUsers': invitedUsersJson, // Include the invitedUsers field here
    };
  }

  @override
  String toString() {
    final userNames = users.map((user) => user.name).join(', ');
    return 'Group information (groupName: $groupName, users: $userNames, description: $description, photo: $photo)';
  }
}
