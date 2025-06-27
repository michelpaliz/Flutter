import 'package:calendar_app_frontend/a-models/group_model/calendar/calendar.dart';
import 'package:calendar_app_frontend/a-models/notification_model/userInvitation_status.dart';

class Group {
  final String id;
  String name;
  final String ownerId; // ID of the group owner
  final Map<String, String> userRoles; // Map of user IDs to their roles
  List<String> userIds;
  DateTime createdTime;
  String description;
  String photo;
  Map<String, UserInviteStatus>? invitedUsers;
  final Calendar calendar; // Single calendar for the group

  Group({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.userRoles,
    required this.userIds,
    required this.createdTime,
    required this.description,
    required this.photo,
    required this.calendar,
    Map<String, UserInviteStatus>? invitedUsers,
  }) : invitedUsers = invitedUsers ?? {};

  factory Group.fromJson(Map<String, dynamic> json) {
    List<String> userIds = List<String>.from(json['userIds'] ?? []);
    Map<String, dynamic> invitedUsersJson = json['invitedUsers'] ?? {};

    Map<String, UserInviteStatus> invitedUsers = invitedUsersJson.map(
      (key, value) => MapEntry(key, UserInviteStatus.fromJson(value)),
    );

    return Group(
      id: json['id'] ?? json['_id'] ?? '', // ✅ fallback for legacy `_id`
      name: json['name'] ?? '',
      ownerId: json['ownerId'] ?? '',
      userRoles: Map<String, String>.from(json['userRoles'] ?? {}),
      userIds: userIds,
      createdTime: json['createdTime'] != null
          ? DateTime.parse(json['createdTime'])
          : DateTime.now(),
      description: json['description'] ?? '',
      photo: json['photo'] ?? '',
      calendar: Calendar.fromJson(json['calendar']),
      invitedUsers: invitedUsers,
    );
  }

  // 🔁 For reading/updating (includes ID)
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // include _id here
      'name': name,
      'ownerId': ownerId,
      'userRoles': userRoles,
      'userIds': userIds,
      'createdTime': createdTime.toIso8601String(),
      'description': description,
      'photo': photo,
      'calendar': calendar.toJson(),
      'invitedUsers': invitedUsers?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  // 🆕 For creating new groups (without ID)
  Map<String, dynamic> toJsonForCreation() {
    return {
      'name': name,
      'ownerId': ownerId,
      'userRoles': userRoles,
      'userIds': userIds,
      'createdTime': createdTime.toIso8601String(),
      'description': description,
      'photo': photo,
      'calendar': calendar.toJson(),
      'invitedUsers': invitedUsers?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  bool isEqual(Group other) {
    return id == other.id &&
        name == other.name &&
        ownerId == other.ownerId &&
        userRoles == other.userRoles &&
        userIds == other.userIds &&
        createdTime == other.createdTime &&
        description == other.description &&
        photo == other.photo &&
        calendar.toJson().toString() == other.calendar.toJson().toString() &&
        _areInvitedUsersEqual(invitedUsers, other.invitedUsers);
  }

  bool _areInvitedUsersEqual(
    Map<String, UserInviteStatus>? map1,
    Map<String, UserInviteStatus>? map2,
  ) {
    if (map1 == null && map2 == null) return true;
    if (map1 == null || map2 == null) return false;
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key) || !map1[key]!.isEqual(map2[key]!))
        return false;
    }
    return true;
  }

  static Group createDefaultGroup() {
    return Group(
      id: 'default_id',
      name: 'Default Group Name',
      ownerId: 'default_owner_id',
      userRoles: {},
      userIds: [],
      createdTime: DateTime.now(),
      description: 'Default Description',
      photo: 'default_photo_url',
      calendar: Calendar.defaultCalendar(),
      invitedUsers: {},
    );
  }

  @override
  String toString() {
    return 'Group{id: $id, name: $name, ownerId: $ownerId, userRoles: $userRoles, userIds: $userIds, createdTime: $createdTime, description: $description, photo: $photo, calendar: $calendar, invitedUsers: $invitedUsers}';
  }
}
