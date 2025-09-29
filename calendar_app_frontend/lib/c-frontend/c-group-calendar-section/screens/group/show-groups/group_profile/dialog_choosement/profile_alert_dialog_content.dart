import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/d-stateManagement/group/group_management.dart';
import 'package:hexora/f-themes/utilities/utilities.dart';
import 'package:hexora/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Builds the content of a profile alert dialog for a group.
///
/// ✅ Features:
/// - Displays group image, name, and creation date
/// - Themed button to navigate to group calendar
/// - Fully theme-aware for dark/light mode
Widget buildProfileDialogContent(BuildContext context, Group group) {
  final theme = Theme.of(context); // Access current theme
  final textTheme = theme.textTheme;
  final colorScheme = theme.colorScheme;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // 🖼️ Group image
      CircleAvatar(
        radius: 30,
        backgroundImage: Utilities.buildProfileImage(group.photoUrl),
      ),
      const SizedBox(height: 8),

      // 📛 Group name
      Text(
        group.name,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: colorScheme.onSurface, // Ensure contrast on dialogs
        ),
      ),
      const SizedBox(height: 8),

      // 📅 Creation date
      Text(
        '${group.createdTime.year}-${group.createdTime.month}-${group.createdTime.day}',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      const SizedBox(height: 15),

      // 📆 Go to calendar button
      TextButton(
        onPressed: () {
          final groupManagement = Provider.of<GroupManagement>(
            context,
            listen: false,
          );
          groupManagement.currentGroup = group;

          Navigator.pushNamed(
            context,
            AppRoutes.groupDashboard, // 👈 goes to dashboard now
            arguments: group,
          );
        },

        // 🎨 Custom button style (you could replace with theme-based styles too)
        style: ButtonStyles.saucyButtonStyle(
          defaultBackgroundColor: colorScheme.primaryContainer,
          pressedBackgroundColor: colorScheme.primary,
          textColor: colorScheme.onPrimaryContainer,
          borderColor: colorScheme.primary,
        ),

        // 📎 Button content
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.dashboard),
          ],
        ),
      ),
    ],
  );
}
