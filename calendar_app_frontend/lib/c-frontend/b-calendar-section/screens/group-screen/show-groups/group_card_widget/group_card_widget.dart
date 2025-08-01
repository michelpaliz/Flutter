import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/show-groups/group_profile/profile_alert_dialog.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Renders a tappable group card with theme-aware styling.
///
/// ✅ Features:
/// - Displays group name and creation date
/// - Opens a profile dialog when tapped
/// - Applies hover styling with color overlay
/// - Uses the app's light/dark theme colors
///
/// Note: This widget does not use a StatefulWidget directly but achieves
/// reactivity through `StatefulBuilder` for hover interactivity.
Widget buildGroupCard(
  BuildContext context,
  Group group,
  User? currentUser,
  UserManagement userManagement,
  GroupManagement groupManagement,
  void Function(String?) updateRole,
) {
  final role = group.userRoles[currentUser?.userName] ?? 'Member';
  final canEdit = role != 'Member'; // Only non-Members can edit the group

  return StatefulBuilder(
    builder: (context, setState) {
      bool isHovered = false;

      return InkWell(
        onTap: () async {
          // Fetch group owner info and open profile dialog
          User groupOwner =
              await userManagement.userService.getUserById(group.ownerId);
          showProfileAlertDialog(
            context,
            group,
            groupOwner,
            currentUser,
            userManagement,
            groupManagement,
            updateRole,
            canEdit,
          );
        },
        onHover: (hovering) => setState(() => isHovered = hovering),
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: buildCard(group, context, isHovered),
        ),
      );
    },
  );
}

/// Builds the visual layout for the group card.
///
/// Applies hover background, theming, and proper typography.
Widget buildCard(Group group, BuildContext context, bool isHovered) {
  final formattedDate = DateFormat('yyyy-MM-dd').format(group.createdTime);

  // Theme-based colors
  final theme = Theme.of(context);
  final textColor = theme.colorScheme.onSurface;
  final cardColor =
      ThemeColors.getCardBackgroundColor(context).withOpacity(0.95);
  final hoverOverlay = theme.hoverColor.withOpacity(0.1);
  final effectiveBackgroundColor = isHovered ? hoverOverlay : cardColor;

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: 2,
    color: effectiveBackgroundColor,
    child: SizedBox(
      width: 150,
      child: Row(
        children: [
          // Group icon
          Padding(
            padding: const EdgeInsets.only(right: 3, left: 4),
            child: Icon(
              Icons.group,
              size: 32,
              color: theme.colorScheme.primary, // Themed icon color
            ),
          ),
          const SizedBox(width: 8),

          // Group name and date
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group creation date
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontFamily: 'lato',
                      color: textColor.withOpacity(0.7), // De-emphasized
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Group name
                  Text(
                    group.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
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
  );
}
