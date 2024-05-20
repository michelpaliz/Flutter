

import 'package:first_project/models/calendar.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';

class GroupDTO {
  final String id;
  String groupName;
  final String ownerId; // ID of the group owner
  final Map<String, String> userRoles; // Map of user IDs to their roles
  final Calendar calendar; // Shared calendar for the group
  List<User> users;
  String  createdTime; // Time the group was created
  bool
      repetitiveEvents; // With this variable, I can check if the members want to have repetitive events at the same time.
  String description; // A description of the group
  String photo; // Add the new field for storing a photo link
  Map<String, UserInviteStatus>?
      invitedUsers; // New field to store invited users and their answers

  GroupDTO({
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


}