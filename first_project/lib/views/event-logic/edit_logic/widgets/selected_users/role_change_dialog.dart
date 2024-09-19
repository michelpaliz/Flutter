import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/invitations_helper/invitation_message_helper.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/invitations_helper/role_dropdown_helper.dart';
import 'package:flutter/material.dart';


class RoleChangeDialog {
  static void show(BuildContext context, String userName, String? selectedRole,
      UserInviteStatus? userInviteStatus, Function(String?) onRoleSelected) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String informativeMessage = InvitationMessageHelper.getInvitationMessage(userInviteStatus);
        bool showRoleDropdown = RoleDropdownHelper.shouldShowRoleDropdown(userInviteStatus);
        String additionalMessage = RoleDropdownHelper.getAdditionalMessage(userInviteStatus);

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
}
