import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/controllers/create_group_controller.dart';
import 'package:first_project/c-frontend/b-group-section/utils/shared/add_user_button.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';

import '../user_list_section.dart';
import '../utils/filter_chips_section.dart';

class EditGroupPeople extends StatefulWidget {
  final Group group;
  final List<User> initialUsers;
  final UserManagement userManagement;
  final GroupManagement groupManagement;
  final NotificationManagement notificationManagement;

  const EditGroupPeople({
    Key? key,
    required this.group,
    required this.initialUsers,
    required this.userManagement,
    required this.groupManagement,
    required this.notificationManagement,
  }) : super(key: key);

  @override
  State<EditGroupPeople> createState() => _EditGroupPeopleState();
}

class _EditGroupPeopleState extends State<EditGroupPeople> {
  late GroupController controller;
  bool showAccepted = true;
  bool showPending = true;
  bool showNotWantedToJoin = true;
  late Map<String, UserInviteStatus> invitedUsers;

  @override
  void initState() {
    super.initState();
    controller = GroupController();

    invitedUsers = widget.group.invitedUsers ?? {};

    controller.initialize(
      user: widget.userManagement.user!,
      userManagement: widget.userManagement,
      groupManagement: widget.groupManagement,
      notificationManagement: widget.notificationManagement,
      context: context,
    );
  }

  Map<String, UserInviteStatus> get filteredInvitedUsers {
    return invitedUsers.entries.where((entry) {
      final status = entry.value.informationStatus;
      return (showPending && status == 'Pending') ||
          (showAccepted && status == 'Accepted') ||
          (showNotWantedToJoin && status == 'NotAccepted');
    }).fold<Map<String, UserInviteStatus>>({}, (map, entry) {
      map[entry.key] = entry.value;
      return map;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddUserButtonDialog(
          currentUser: widget.userManagement.user,
          group: widget.group, // 👈 here you pass the group! because it's edit
          controller: controller,
        ),
        const SizedBox(height: 12),
        FilterChipsSection(
          showAccepted: showAccepted,
          showPending: showPending,
          showNotWantedToJoin: showNotWantedToJoin,
          onFilterChange: (filter, isSelected) {
            setState(() {
              switch (filter) {
                case 'Accepted':
                  showAccepted = isSelected;
                  break;
                case 'Pending':
                  showPending = isSelected;
                  break;
                case 'NotAccepted':
                  showNotWantedToJoin = isSelected;
                  break;
              }
            });
          },
        ),
        const SizedBox(height: 12),
        UserListSection(
          filteredUsers: {}, // Optional: filter `initialUsers` if needed
          usersRoles: controller.userRoles,
          usersInvitations: filteredInvitedUsers,
          usersInvitationAtFirst: invitedUsers,
          group: widget.group,
          usersInGroup: widget.initialUsers,
          userManagement: widget.userManagement,
          groupManagement: widget.groupManagement,
          notificationManagement: widget.notificationManagement,
          onChangeRole: (userName, newRole) {
            controller.onRolesUpdated({userName: newRole});
          },
          onUserRemoved: (userName) {
            controller.removeUser(userName);
          },
        ),
      ],
    );
  }
}
