import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/l10n/app_localizations.dart';

class GroupUpdateController {
  final BuildContext context;
  final Group originalGroup;
  final String groupName;
  final String groupDescription;
  final String imageUrl;
  final User currentUser;
  final Map<String, String> userRoles;
  final Map<String, UserInviteStatus> usersInvitations;

  final UserDomain userDomain;
  final GroupDomain groupDomain;

  GroupUpdateController({
    required this.context,
    required this.originalGroup,
    required this.groupName,
    required this.groupDescription,
    required this.imageUrl,
    required this.currentUser,
    required this.userRoles,
    required this.usersInvitations,
    required this.userDomain,
    required this.groupDomain,
  });

  Future<bool> performGroupUpdate() async {
    if (groupName.trim().isEmpty || groupDescription.trim().isEmpty) {
      _showError(AppLocalizations.of(context)!.requiredTextFields);
      return false;
    }

    try {
      // Persist exactly what the child produced (no frontend notifications)
      final updatedGroup = Group(
        id: originalGroup.id,
        name: groupName,
        ownerId: originalGroup.ownerId, // preserve owner
        userRoles: userRoles, // roles from UI
        invitedUsers: usersInvitations, // <-- persist invites
        userIds: originalGroup.userIds, // members unchanged here
        createdTime: originalGroup.createdTime, // preserve creation time
        description: groupDescription,
        photoUrl: imageUrl,
      );

      await groupDomain.updateGroup(updatedGroup, userDomain);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.groupEdited)),
      );

      Navigator.pop(context);
      return true;
    } catch (e) {
      // Optional: log error detail
      // debugPrint('Error updating group: $e');
      _showError(AppLocalizations.of(context)!.failedToEditGroup);
      return false;
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}
