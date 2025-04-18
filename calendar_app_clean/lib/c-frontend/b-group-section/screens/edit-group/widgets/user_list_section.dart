import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/functions/user_removal_service.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/selected_users/invitation_functions/dismiss_user_dialog.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/selected_users/invitation_functions/role_change_dialog.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/selected_users/user_tile.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';

class UserListSection extends StatelessWidget {
  final Map<String, User> filteredUsers;
  final Map<String, String> usersRoles;
  final Map<String, UserInviteStatus> usersInvitations;
  final Map<String, UserInviteStatus> usersInvitationAtFirst;
  final Group group;
  final List<User> usersInGroup;
  final UserManagement userManagement;
  final GroupManagement groupManagement;
  final NotificationManagement notificationManagement;
  final Function(String userName, String newRole) onChangeRole;
  final Function(String userName) onUserRemoved;

  const UserListSection({
    Key? key,
    required this.filteredUsers,
    required this.usersRoles,
    required this.usersInvitations,
    required this.usersInvitationAtFirst,
    required this.group,
    required this.usersInGroup,
    required this.userManagement,
    required this.groupManagement,
    required this.notificationManagement,
    required this.onChangeRole,
    required this.onUserRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: filteredUsers.entries.map((entry) {
        final userName = entry.key;
        final user = entry.value;
        final selectedRole = usersRoles[userName];
        final userInviteStatus = usersInvitations[userName];

        return UserTile(
          userName: userName,
          user: user,
          roleValue: selectedRole ?? 'Member',
          onChangeRole: (name) {
            RoleChangeDialog.show(
              context,
              userName,
              selectedRole ?? 'Member', // ✅ Null-safe default role
              userInviteStatus,
              (newRole) => onChangeRole(userName, newRole!),
              usersRoles,
              usersInvitations,
              usersInvitationAtFirst,
            );
          },
          onDismissed: (userName) {
            showDialog(
              context: context,
              builder: (ctx) => DismissUserDialog(
                userName: userName,
                isNewUser: !usersInvitationAtFirst.containsKey(userName),
                onCancel: () => Navigator.of(ctx).pop(),
                onConfirm: () async {
                  final removalService = UserRemovalService(
                    context: context,
                    usersInGroup: usersInGroup,
                    usersInvitations: usersInvitations,
                    usersRoles: usersRoles,
                    groupManagement: groupManagement,
                    userManagement: userManagement,
                    group: group,
                    notificationManagement: notificationManagement,
                  );

                  final status = usersInvitations[userName]?.invitationAnswer;
                  final invitationStatus = status == 'accepted'
                      ? true
                      : status == 'declined'
                          ? false
                          : null;

                  final success = await removalService.performUserRemoval(
                    userName,
                    invitationStatus,
                    usersInvitationAtFirst.containsKey(userName),
                  );

                  Navigator.of(ctx).pop();

                  final snackBar = SnackBar(
                    content: Text(success
                        ? 'User $userName removed successfully.'
                        : 'Failed to remove user $userName.'),
                    duration: Duration(seconds: 5),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  if (success) onUserRemoved(userName);
                },
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
