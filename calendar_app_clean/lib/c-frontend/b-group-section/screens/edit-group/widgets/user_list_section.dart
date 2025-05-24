import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/b-group-section/utils/selected_users/invitation_functions/dismiss_user_dialog.dart';
import 'package:first_project/c-frontend/b-group-section/utils/shared/group_user_card.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/functions/user/user_removal_service.dart';
import 'package:first_project/d-stateManagement/group/group_management.dart';
import 'package:first_project/d-stateManagement/notification/notification_management.dart';
import 'package:first_project/d-stateManagement/user/user_management.dart';
import 'package:first_project/f-themes/shape/rounded/rounded_section_card.dart';
import 'package:flutter/material.dart';

class UserListSection extends StatelessWidget {
  final Map<String, User> newUsers;
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
  final bool showPending;
  final bool showAccepted;
  final bool showNotWantedToJoin;
  final bool showNewUsers;
  final bool showExpired;

  const UserListSection(
      {Key? key,
      required this.newUsers,
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
      required this.showPending,
      required this.showAccepted,
      required this.showNotWantedToJoin,
      required this.showNewUsers,
      required this.showExpired})
      : super(key: key);

  bool _isDuplicate(String userName) {
    final isNew = newUsers.containsKey(userName);
    final isInGroup = usersInGroup.any((user) => user.name == userName);
    final isInvited = usersInvitations.containsKey(userName);

    final isDuplicate = isNew || (isInGroup && !isInvited);

    print('🧪 _isDuplicate → $userName: '
        'isNew: $isNew, isInGroup: $isInGroup, isInvited: $isInvited, '
        '→ isDuplicate: $isDuplicate');

    return isDuplicate;
  }

  @override
  Widget build(BuildContext context) {
    print('👥 usersInGroup: ${usersInGroup.map((u) => u.name).toList()}');
    print('📩 invitedUsers: ${usersInvitations.keys.toList()}');

    // 2. Filtered list of invited users based on toggle states
    final filteredInvitedUsers = usersInvitations.entries.where((entry) {
      final status = entry.value.informationStatus;
      final userName = entry.key;

      print('🔎 Checking invited user $userName with raw status: "$status"');

      if (_isDuplicate(userName)) return false;

      final normalizedStatus = status.trim().toLowerCase();

      if (normalizedStatus == 'pending' && showPending) return true;
      if (normalizedStatus == 'accepted' && showAccepted) return true;
      if (normalizedStatus == 'notaccepted' && showNotWantedToJoin) return true;
      if (normalizedStatus == 'expired' && showExpired) return true;

      return false;
    }).toList();

    return RoundedSectionCard(
      title: 'Group Members',
      child: Column(
        children: [
          // 1. Newly added users (only if showNewUsers)
          if (showNewUsers)
            ...newUsers.entries.map((entry) {
              final userName = entry.key;
              final user = entry.value;
              final selectedRole = usersRoles[userName];

              return GroupUserCard(
                userName: userName,
                role: selectedRole ?? 'Member',
                photoUrl: user.photoUrl,
                isAdmin: selectedRole == 'Administrator',
                onRemove: () => _showDismissDialog(context, userName),
              );
            }).toList(),

          // 2. Invited users (filtered by status dynamically)
          if (filteredInvitedUsers.isEmpty) ...[
            // Custom message when there are no invited users matching the filters
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No invited users to display.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          ] else ...[
            // Render filtered invited users
            ...filteredInvitedUsers.map((entry) {
              final userName = entry.key;
              final inviteStatus = entry.value;

              print('📦 Rendering GroupUserCard for invited user: '
                  '$userName → ${inviteStatus.informationStatus}');

              return GroupUserCard(
                userName: userName,
                role: inviteStatus.role,
                photoUrl: null,
                isAdmin: false,
                status: inviteStatus.informationStatus,
                sendingDate: inviteStatus.sendingDate,
                onRemove: null,
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  void _showDismissDialog(BuildContext context, String userName) {
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
            duration: const Duration(seconds: 5),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);

          if (success) onUserRemoved(userName);
        },
      ),
    );
  }
}
