import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/notification_model/userInvitation_status.dart';

class GroupInitializationService {
  final Group group;
  final TextEditingController descriptionController;

  late String groupName;
  late String groupDescription;
  late String imageURL;
  late Map<String, String> usersRoles;
  late Map<String, UserInviteStatus> usersInvitationAtFirst;
  late Map<String, UserInviteStatus> usersInvitations;

  GroupInitializationService({
    required this.group,
    required this.descriptionController,
  }) {
    _initialize();
  }

  void _initialize() {
    groupName = group.name;
    groupDescription = group.description;
    imageURL = group.photoUrl ?? '';
    usersRoles = Map<String, String>.from(group.userRoles);

    // Handle invited users (deep copy)
    if (group.invitedUsers != null && group.invitedUsers!.isNotEmpty) {
      usersInvitationAtFirst = Map<String, UserInviteStatus>.from(
        group.invitedUsers!,
      );
      usersInvitations = usersInvitationAtFirst.map(
        (key, value) => MapEntry(key, value.copy()),
      );
    } else {
      usersInvitationAtFirst = {};
      usersInvitations = {};
    }

    // Setup controller
    descriptionController.text = groupDescription;
  }
}
