import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/controllers/create_group_controller.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/widgets/edit_group_body/edit_group_admin_info.dart';
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
  late Map<String, UserInviteStatus> invitedUsers;
  Map<String, User> newUsers = {};

  bool showAccepted = true;
  bool showPending = true;
  bool showNotWantedToJoin = true;
  bool showNewUsers = true;
  bool showExpired = true;
  late User? _currentUser;
  late String _currentUserRoleValue;

  @override
  void initState() {
    super.initState();
    controller = GroupController();

    _currentUser = widget.userManagement.user;

    invitedUsers = widget.group.invitedUsers ?? {};

    controller.initialize(
      user: _currentUser!,
      userManagement: widget.userManagement,
      groupManagement: widget.groupManagement,
      notificationManagement: widget.notificationManagement,
      context: context,
    );

    _currentUserRoleValue = _currentUser!.id == widget.group.ownerId
        ? 'Administrator'
        : widget.group.userRoles[_currentUser!.userName] ?? 'Member';
  }

  void onNewUserAdded(User user) {
    setState(() {
      newUsers[user.name] = user;
    });
  }

  Map<String, User> get filteredNewUsers {
    if (!showNewUsers) return {};
    return newUsers;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddUserButtonDialog(
          currentUser: widget.userManagement.user,
          group: widget.group,
          controller: controller,
          onUserAdded: onNewUserAdded,
        ),
        const SizedBox(height: 12),
        if (_currentUserRoleValue == 'Administrator')
          EditGroupAdminInfo(currentUser: _currentUser!),
        const SizedBox(height: 12),
        FilterChipsSection(
          showAccepted: showAccepted,
          showPending: showPending,
          showNotWantedToJoin: showNotWantedToJoin,
          showNewUsers: showNewUsers,
          showExpired: showExpired,
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
                case 'New Users':
                  showNewUsers = isSelected;
                  break;
                case 'Expired':
                  showExpired = isSelected;
                  break;
              }
            });
          },
        ),
        const SizedBox(height: 12),
        UserListSection(
          newUsers: filteredNewUsers,
          usersRoles: controller.userRoles,
          usersInvitations: invitedUsers,
          usersInvitationAtFirst: invitedUsers,
          group: widget.group,
          usersInGroup: widget.initialUsers,
          userManagement: widget.userManagement,
          groupManagement: widget.groupManagement,
          notificationManagement: widget.notificationManagement,
          showPending: showPending,
          showAccepted: showAccepted,
          showNotWantedToJoin: showNotWantedToJoin,
          showNewUsers: showNewUsers,
          showExpired: showExpired,
          onChangeRole: (userName, newRole) {
            controller.onRolesUpdated({userName: newRole});
          },
          onUserRemoved: (userName) {
            controller.removeUser(userName);
            setState(() {
              newUsers.remove(userName);
            });
          },
        ),
      ],
    );
  }
}
