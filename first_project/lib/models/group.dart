
import 'calendar.dart';

class Group {
  final String id;
  final String groupName;
  final String ownerId; // ID of the group owner
  final Map<String, String> userRoles; // Map of user IDs to their roles
  final Calendar calendar; // Shared calendar for the group

  Group({
    required this.id,
    required this.groupName,
    required this.ownerId,
    required this.userRoles,
    required this.calendar,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      groupName: json['groupName'],
      ownerId: json['ownerId'],
      userRoles: Map<String, String>.from(json['userRoles']),
      calendar: Calendar.fromJson(json['calendar']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupName': groupName,
      'ownerId': ownerId,
      'userRoles': userRoles,
      'calendar': calendar.toJson(),
    };
  }
}
