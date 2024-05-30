import 'package:first_project/models/userInvitationStatus.dart';

import 'calendar.dart';

class Group {
  final String id;
  String groupName;
  final String ownerId; // ID of the group owner
  final Map<String, String> userRoles; // Map of user IDs to their roles
  final Calendar calendar; // Shared calendar for the group
  List<String> userIds; // Changed from List<User> to List<String>
  DateTime createdTime; // Time the group was created
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
    required this.userIds, // Changed from users to userIds
    required this.createdTime,
    this.repetitiveEvents = false,
    required this.description,
    required this.photo,
    Map<String, UserInviteStatus>? invitedUsers,
  }) : invitedUsers = invitedUsers ?? {};


  factory Group.fromJson(Map<String, dynamic> json) {
    List<String> userIds = List<String>.from(json['userIds'] ?? []);
    Map<String, dynamic> invitedUsersJson = json['invitedUsers'] ?? {};

    Map<String, UserInviteStatus> invitedUsers = invitedUsersJson
        .map((key, value) => MapEntry(key, UserInviteStatus.fromJson(value)));

    return Group(
      id: json['id'] ?? '',
      groupName: json['groupName'] ?? '',
      ownerId: json['ownerId'] ?? '',
      userRoles: Map<String, String>.from(json['userRoles'] ?? {}),
      calendar: Calendar.fromJson(json['calendar'] ?? {}),
      userIds: userIds,
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
      'userIds': userIds,
      'createdTime': createdTime.toIso8601String(),
      'repetitiveEvents': repetitiveEvents,
      'description': description,
      'photo': photo,
      'invitedUsers': invitedUsersJson,
    };
  }

  @override
  String toString() {
    return 'Group{id: $id, groupName: $groupName, ownerId: $ownerId, userRoles: $userRoles, calendar: $calendar, userIds: $userIds, createdTime: $createdTime, repetitiveEvents: $repetitiveEvents, description: $description, photo: $photo, invitedUsers: $invitedUsers}';
  }
}
