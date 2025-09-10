import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/invited-user/group_role_extension.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/screens/group-screen/show-groups/group_profile/dialog_choosement/profile_alert_dialog.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Renders a tappable group card with theme-aware styling.
Widget buildGroupCard(
  BuildContext context,
  Group group,
  User? currentUser,
  UserManagement userManagement,
  GroupManagement groupManagement,
  void Function(String?) updateRole,
) {
  final role = group.getRoleForUser(currentUser!);
  final canEdit =
      role == 'Owner' || role == 'Administrator' || role == 'Co-Administrator';

  return StatefulBuilder(
    builder: (context, setState) {
      bool isHovered = false;

      return InkWell(
        onTap: () async {
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
Widget buildCard(Group group, BuildContext context, bool isHovered) {
  final formattedDate = DateFormat('yyyy-MM-dd').format(group.createdTime);

  final theme = Theme.of(context);
  final textColor = theme.colorScheme.onSurface;
  final cardColor =
      ThemeColors.getCardBackgroundColor(context).withOpacity(0.95);
  final hoverOverlay = theme.hoverColor.withOpacity(0.08);
  final effectiveBackgroundColor = isHovered ? hoverOverlay : cardColor;

  final participantCount = group.userIds.length;

  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    elevation: isHovered ? 6 : 2,
    color: effectiveBackgroundColor,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Group image or fallback icon
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (group.photoUrl != null && group.photoUrl!.isNotEmpty)
                    ? Image.network(
                        group.photoUrl!, // ✅ use non-nullable with "!"
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.group,
                          size: 48,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.group,
                        size: 48,
                        color: theme.colorScheme.primary,
                      ),
              ),

              const SizedBox(width: 12),

              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group name
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'lato',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Created date
                    Text(
                      "Created: $formattedDate",
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.7),
                        fontFamily: 'lato',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating participant badge
        Positioned(
          top: -6,
          right: -6,
          child: Material(
            elevation: 3,
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    '$participantCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
