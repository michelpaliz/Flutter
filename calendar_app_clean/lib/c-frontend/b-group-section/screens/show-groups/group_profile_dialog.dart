import 'package:first_project/c-frontend/b-group-section/screens/edit-group/edit_group_data.dart';
import 'package:first_project/c-frontend/b-group-section/screens/show-groups/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/f-themes/widgets/view-item-styles/button_styles.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../routes/appRoutes.dart';

// Shows group info (name, date, image)
// Offers Edit, Remove, and Leave actions
// Uses GroupController for permissions + logic

void showProfileAlertDialog(
  BuildContext context,
  Group group,
  User owner,
  User? currentUser,
  UserManagement userManagement,
  GroupManagement groupManagement,
  void Function(String?) updateRole,
) {
  final user = currentUser ?? userManagement.user!;
  final hasPermission = GroupController.hasPermissions(user, group);
  final role = GroupController.getRole(user, group.userRoles);
  updateRole(role); // update state

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  Utilities.buildProfileImage(group.photo.toString()),
            ),
            const SizedBox(height: 8),
            Text(
              group.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(DateFormat('yyyy-MM-dd').format(group.createdTime)),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                groupManagement.currentGroup = group;
                Navigator.pushNamed(
                  context,
                  AppRoutes.groupCalendar,
                  arguments: group,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_rounded),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.goToCalendar),
                ],
              ),
              style: ButtonStyles.saucyButtonStyle(
                defaultBackgroundColor: const Color.fromARGB(255, 229, 117, 151),
                pressedBackgroundColor: const Color.fromARGB(255, 227, 62, 98),
                textColor: const Color.fromARGB(255, 26, 26, 26),
                borderColor: const Color.fromARGB(255, 53, 10, 7),
              ),
            ),
          ],
        ),
        actions: hasPermission
            ? [
                TextButton(
                  onPressed: () async {
                    var selectedGroup = await groupManagement.groupService
                        .getGroupById(group.id);
                    List<User> users = [];
                    for (var userID in selectedGroup.userIds) {
                      final user = await userManagement.userService
                          .getUserById(userID);
                      users.add(user);
                    }

                    Navigator.pushNamed(
                      context,
                      AppRoutes.editGroupData,
                      arguments: EditGroupData(
                        group: selectedGroup,
                        users: users,
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.edit),
                ),
                TextButton(
                  onPressed: () async {
                    final confirm = await _showConfirmationDialog(
                      context,
                      AppLocalizations.of(context)!.questionDeleteGroup,
                    );
                    if (confirm) {
                      await GroupController.removeGroup(
                        group: group,
                        userManagement: userManagement,
                        groupManagement: groupManagement,
                      );
                      if (context.mounted) Navigator.pop(context); // close dialog
                    }
                  },
                  child: Text(AppLocalizations.of(context)!.remove),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Currently you are a/an $role of this group "),
                ),
                TextButton(
                  onPressed: () async {
                    final confirm = await _showConfirmationDialog(
                      context,
                      user.id == group.ownerId
                          ? 'Are you sure you want to dissolve this group?'
                          : 'Are you sure you want to leave this group?',
                    );
                    if (confirm) {
                      await GroupController.leaveGroup(
                        group: group,
                        user: user,
                        groupManagement: groupManagement,
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text("Leave group"),
                ),
              ],
      );
    },
  );
}

Future<bool> _showConfirmationDialog(BuildContext context, String message) async {
  return await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Confirm'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      ) ??
      false;
}
