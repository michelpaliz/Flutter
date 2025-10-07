import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/invited-user/group_role_extension.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/show-groups/group_profile/dialog_choosement/profile_alert_dialog.dart';
import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:intl/intl.dart';

/// Renders a tappable group card with theme-aware styling.
Widget buildGroupCard(
  BuildContext context,
  Group group,
  User? currentUser,
  UserDomain userDomain,
  GroupDomain groupDomain,
  void Function(String?) updateRole,
) {
  final role =
      (currentUser != null) ? group.getRoleForUser(currentUser) : 'Member';

  final canEdit =
      role == 'Owner' || role == 'Administrator' || role == 'Co-Administrator';

  return StatefulBuilder(
    builder: (context, setState) {
      bool isHovered = false;

      return InkWell(
        onTap: () async {
          try {
            // ✅ Use the repository (handles token) instead of service
            final groupOwner =
                await userDomain.userRepository.getUserById(group.ownerId);

            // Open the profile dialog
            // (use groupOwner fetched via repository)
            // ignore: use_build_context_synchronously
            showProfileAlertDialog(
              context,
              group,
              groupOwner,
              currentUser,
              userDomain,
              groupDomain,
              updateRole,
              canEdit,
            );
          } catch (e) {
            // Optional: show a toast/snackbar on error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load group owner: $e')),
            );
          }
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
                        group.photoUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
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
