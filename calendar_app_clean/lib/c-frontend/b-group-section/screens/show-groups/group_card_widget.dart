import 'package:first_project/c-frontend/b-group-section/screens/show-groups/group_profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';

// Shows group info (name, date, image)
// Offers Edit, Remove, and Leave actions
// Uses GroupController for permissions + logic

Widget buildGroupCard(
  BuildContext context,
  Group group,
  User? currentUser,
  UserManagement userManagement,
  GroupManagement groupManagement,
  void Function(String?) updateRole,
) {
  bool isHovered = false;

  return InkWell(
    onTap: () async {
      User groupOwner = await userManagement.userService.getUserById(group.ownerId);
      showProfileAlertDialog(
        context,
        group,
        groupOwner,
        currentUser,
        userManagement,
        groupManagement,
        updateRole,
      );
    },
    onHover: (hovering) {
      isHovered = hovering;
    },
    child: MouseRegion(
      onEnter: (_) => isHovered = true,
      onExit: (_) => isHovered = false,
      child: buildCard(group, context, isHovered),
    ),
  );
}

Widget buildCard(Group group, BuildContext context, bool isHovered) {
  final textColor = ThemeColors.getTextColor(context);
  final cardBackgroundColor = ThemeColors.getCardBackgroundColor(context);
  final formattedDate = DateFormat('yyyy-MM-dd').format(group.createdTime);
  final backgroundColor = isHovered
      ? const Color.fromARGB(57, 145, 182, 195)
      : const Color.fromARGB(255, 255, 255, 255);

  return Container(
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: SizedBox(
        width: 150,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 3, left: 4),
              child: Icon(Icons.group, size: 32, color: Colors.blue),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontFamily: 'lato',
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      group.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 48, 133, 141),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'lato',
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      color: backgroundColor,
    ),
  );
}
