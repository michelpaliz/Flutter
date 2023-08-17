
import 'package:first_project/models/user.dart';

import 'calendar.dart';

class Group {
  final String id;
  final String groupName;
  final String? ownerId; // ID of the group owner
  final Map<String, String> userRoles; // Map of user IDs to their roles
final Calendar? calendar; // Shared calendar for the group
  List<User> users;
   // List of users in the group

  Group({
    required this.id,
    required this.groupName,
    required this.ownerId,
    required this.userRoles,
    required this.calendar,
    required this.users,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    // Parse the list of users from the JSON data
    List<dynamic>? usersJson = json['users'];
    List<User> users = usersJson != null
        ? usersJson.map((userJson) => User.fromJson(userJson)).toList()
        : [];

    return Group(
      id: json['id'],
      groupName: json['groupName'],
      ownerId: json['ownerId'],
      userRoles: Map<String, String>.from(json['userRoles']),
      calendar: Calendar.fromJson(json['calendar']),
      users: users,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert the list of users to JSON data
    List<Map<String, dynamic>> usersJson =
        users.map((user) => user.toJson()).toList();

    return {
      'id': id,
      'groupName': groupName,
      'ownerId': ownerId,
      'userRoles': userRoles,
      // 'calendar': calendar?.toJson(),
      'users': usersJson,
    };
  }
}
