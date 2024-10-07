import 'package:first_project/a-models/model/group_data/calendar.dart';
import 'package:first_project/a-models/model/group_data/group.dart';
import 'package:first_project/a-models/userInvitationStatus.dart';

class GroupDTO {
  final String id;
  final String name;
  final String ownerId;
  final Map<String, String> userRoles; // Map of user IDs to roles
  final String calendarId; // Use calendar ID instead of full Calendar object
  final List<String> userIds; // List of user IDs
  final DateTime createdTime;
  final bool repetitiveEvents;
  final String description;
  final String photo;
  final Map<String, String>? invitedUsers; // Map userId -> inviteStatus

  GroupDTO({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.userRoles,
    required this.calendarId,
    required this.userIds,
    required this.createdTime,
    required this.repetitiveEvents,
    required this.description,
    required this.photo,
    this.invitedUsers,
  });

  // Convert DTO to Group (toGroup)
  Group toGroup(Calendar calendar) {
    return Group(
      id: id,
      name: name,
      ownerId: ownerId,
      userRoles: userRoles,
      calendar: calendar, // Assuming Calendar.getById retrieves Calendar by its ID
      userIds: userIds,
      createdTime: createdTime,
      repetitiveEvents: repetitiveEvents,
      description: description,
      photo: photo,
      invitedUsers: invitedUsers != null
          ? invitedUsers!.map((key, value) => MapEntry(key, UserInviteStatus.fromString(value))) // Convert string to UserInviteStatus
          : {},
    );
  }

  // Convert Group to DTO (fromGroup)
  factory GroupDTO.fromGroup(Group group) {
    return GroupDTO(
      id: group.id,
      name: group.name,
      ownerId: group.ownerId,
      userRoles: group.userRoles,
      calendarId: group.calendar.id, // Extract the calendar ID
      userIds: group.userIds,
      createdTime: group.createdTime,
      repetitiveEvents: group.repetitiveEvents,
      description: group.description,
      photo: group.photo,
      invitedUsers: group.invitedUsers?.map((key, value) => MapEntry(key, value.status.toString())), // Convert UserInviteStatus to string
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'userRoles': userRoles,
      'calendarId': calendarId, // Save only calendar ID
      'userIds': userIds,
      'createdTime': createdTime.toIso8601String(),
      'repetitiveEvents': repetitiveEvents,
      'description': description,
      'photo': photo,
      'invitedUsers': invitedUsers, // Save invited users as map of userId -> status
    };
  }

  // Convert JSON to GroupDTO
  factory GroupDTO.fromJson(Map<String, dynamic> json) {
    return GroupDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['ownerId'] as String,
      userRoles: Map<String, String>.from(json['userRoles'] ?? {}),
      calendarId: json['calendarId'] as String, // Parse calendar ID
      userIds: List<String>.from(json['userIds'] ?? []),
      createdTime: DateTime.parse(json['createdTime']),
      repetitiveEvents: json['repetitiveEvents'] as bool,
      description: json['description'] as String,
      photo: json['photo'] as String,
      invitedUsers: Map<String, String>.from(json['invitedUsers'] ?? {}),
    );
  }
}
