import 'package:flutter/material.dart';
import 'package:first_project/models/userInvitationStatus.dart';

class RoleChangeDialog {
  static void show(BuildContext context, String userName, String? selectedRole, 
      UserInviteStatus? userInviteStatus, Function(String?) onRoleSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String informativeMessage = _getInvitationMessage(userInviteStatus);
        bool showRoleDropdown = _shouldShowRoleDropdown(userInviteStatus);
        String additionalMessage = _getAdditionalMessage(userInviteStatus);

        return AlertDialog(
          title: Text('Change Role for $userName'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (userInviteStatus != null)
                    ListTile(
                      title: Text("Invitation Status: ${userInviteStatus.status}"),
                      subtitle: Text(informativeMessage),
                    ),
                  if (additionalMessage.isNotEmpty) Text(additionalMessage),
                  SizedBox(height: 20),
                  if (showRoleDropdown)
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: ['Co-Administrator', 'Member'].map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (String? newRole) {
                        setState(() {
                          selectedRole = newRole;
                        });
                        onRoleSelected(newRole);
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Role',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                        border: OutlineInputBorder(),
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onRoleSelected(selectedRole);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static String _getInvitationMessage(UserInviteStatus? userInviteStatus) {
    if (userInviteStatus == null) return 'No invitation record found for this user.';

    if (userInviteStatus.invitationAnswer == null) {
      return 'The invitation is pending. No action is required yet.';
    } else if (userInviteStatus.invitationAnswer == false) {
      return _getDeclinedMessage(userInviteStatus);
    } else if (userInviteStatus.invitationAnswer == true) {
      return 'The user accepted the invitation and is already in the group.';
    }

    return 'Unknown invitation status.';
  }

  static String _getDeclinedMessage(UserInviteStatus userInviteStatus) {
    if (userInviteStatus.attempts == 1) {
      return 'The user declined the invitation. You can resend the invitation after 2 weeks.';
    } else if (userInviteStatus.attempts == 2) {
      return 'The user declined the invitation again. You can resend the invitation after 1 month.';
    } else if (userInviteStatus.attempts >= 3) {
      return 'The user has declined the invitation three times. No more attempts are allowed.';
    }
    return '';
  }

  static bool _shouldShowRoleDropdown(UserInviteStatus? userInviteStatus) {
    if (userInviteStatus == null) return false;

    final int daysSinceSent =
        DateTime.now().difference(userInviteStatus.sendingDate).inDays;

    if (userInviteStatus.invitationAnswer == false) {
      if (userInviteStatus.attempts == 1 && daysSinceSent >= 2) {
        return true;
      } else if (userInviteStatus.attempts == 2 && daysSinceSent >= 30) {
        return true;
      }
    } else if (userInviteStatus.invitationAnswer == true) {
      return true;
    }
    return false;
  }

  static String _getAdditionalMessage(UserInviteStatus? userInviteStatus) {
    if (userInviteStatus == null) return '';

    final int daysSinceSent =
        DateTime.now().difference(userInviteStatus.sendingDate).inDays;

    if (userInviteStatus.invitationAnswer == false) {
      if (userInviteStatus.attempts == 1 && daysSinceSent >= 2) {
        return 'Time has passed. You can now change the role and resend the invitation.';
      } else if (userInviteStatus.attempts == 2 && daysSinceSent >= 30) {
        return 'Time has passed. You can now change the role and resend the invitation.';
      }
    }
    return '';
  }
}
