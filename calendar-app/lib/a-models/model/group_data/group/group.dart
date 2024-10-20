import 'package:first_project/a-models/model/notification/userInvitationStatus.dart';

class Group {
  final String id;
  String name;
  final String ownerId; // ID of the group owner
  final Map<String, String> userRoles; // Map of user IDs to their roles
  List<String> calendarIds; // Changed from List<Calendar> to List<String> for calendar IDs
  List<String> userIds; // List of user IDs
  DateTime createdTime; // Time the group was created
  String description; // Description of the group
  String photo; // Photo URL of the group
  Map<String, UserInviteStatus>? invitedUsers; // Invited users and their status

  Group({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.userRoles,
    required this.calendarIds, // Calendar references by IDs
    required this.userIds, // User IDs
    required this.createdTime,
    required this.description,
    required this.photo,
    Map<String, UserInviteStatus>? invitedUsers, // Invited users
  }) : invitedUsers = invitedUsers ?? {};

  /// Factory method to create a `Group` object from JSON data
  factory Group.fromJson(Map<String, dynamic> json) {
    List<String> userIds = List<String>.from(json['userIds'] ?? []);
    List<String> calendarIds = List<String>.from(json['calendarIds'] ?? []); // Handling calendar IDs as a list of strings
    Map<String, dynamic> invitedUsersJson = json['invitedUsers'] ?? {};

    Map<String, UserInviteStatus> invitedUsers = invitedUsersJson.map(
        (key, value) => MapEntry(key, UserInviteStatus.fromJson(value)));

    return Group(
      id: json['id'] ?? '',
      name: json['groupName'] ?? '',
      ownerId: json['ownerId'] ?? '',
      userRoles: Map<String, String>.from(json['userRoles'] ?? {}),
      calendarIds: calendarIds, // Calendar IDs from JSON
      userIds: userIds,
      createdTime: json['createdTime'] != null
          ? DateTime.parse(json['createdTime'])
          : DateTime.now(),
      description: json['description'] ?? '',
      photo: json['photo'] ?? '', // Parse the photo field
      invitedUsers: invitedUsers,
    );
  }

  /// Convert the `Group` object to JSON format
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
      'groupName': name,
      'ownerId': ownerId,
      'userRoles': userRoles,
      'calendarIds': calendarIds, // Calendar IDs to JSON
      'userIds': userIds,
      'createdTime': createdTime.toIso8601String(),
      'description': description,
      'photo': photo,
      'invitedUsers': invitedUsersJson,
    };
  }

  /// Check if two groups are equal by comparing their fields
  bool isEqual(Group other) {
    return id == other.id &&
        name == other.name &&
        ownerId == other.ownerId &&
        userRoles == other.userRoles &&
        calendarIds == other.calendarIds && // Compare calendar IDs
        userIds == other.userIds &&
        createdTime == other.createdTime &&
        description == other.description &&
        photo == other.photo &&
        _areInvitedUsersEqual(invitedUsers, other.invitedUsers);
  }

  /// Helper method to compare invited users
  bool _areInvitedUsersEqual(
      Map<String, UserInviteStatus>? map1, Map<String, UserInviteStatus>? map2) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key) || !map1[key]!.isEqual(map2[key]!)) return false;
    }
    return true;
  }

  /// Create a default `Group` object with default values
  static Group createDefaultGroup() {
    return Group(
      id: 'default_id',
      name: 'Default Group Name',
      ownerId: 'default_owner_id',
      userRoles: {}, // Empty map for user roles
      calendarIds: [], // Empty list for calendar IDs
      userIds: [], // Empty list for user IDs
      createdTime: DateTime.now(), // Current time as default
      description: 'Default Description',
      photo: 'default_photo_url', // Default photo URL
      invitedUsers: {}, // Empty map for invited users
    );
  }

  @override
  String toString() {
    return 'Group{id: $id, groupName: $name, ownerId: $ownerId, userRoles: $userRoles, calendarIds: $calendarIds, userIds: $userIds, createdTime: $createdTime, description: $description, photo: $photo, invitedUsers: $invitedUsers}';
  }
}
