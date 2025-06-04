import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/f-themes/palette/app_colors.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class AdminWithFiltersSection extends StatelessWidget {
  final User currentUser;
  final bool showAccepted;
  final bool showPending;
  final bool showNotWantedToJoin;
  final bool showNewUsers;
  final bool showExpired;
  final Function(String filter, bool isSelected) onFilterChange;

  const AdminWithFiltersSection({
    super.key,
    required this.currentUser,
    required this.showAccepted,
    required this.showPending,
    required this.showNotWantedToJoin,
    required this.showNewUsers,
    required this.showExpired,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    // Get dynamic background for the container
    final Color containerBg = ThemeColors.getContainerBackgroundColor(context);
    // Contrast text/icon color based on that bg
    final Color contrastText =
        ThemeColors.getContrastTextColor(context, containerBg);

    return Card(
      color: containerBg,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Admin Info
            Row(
              children: [
                CircleAvatar(
                  child: Icon(Icons.person, color: contrastText),
                  backgroundColor: AppColors.secondary.withOpacity(0.2),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: contrastText,
                          ),
                    ),
                    Text(
                      'Administrator',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: contrastText.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Filters
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(context, "New Users", showNewUsers),
                _buildFilterChip(context, "Pending", showPending),
                _buildFilterChip(context, "Accepted", showAccepted),
                _buildFilterChip(context, "NotAccepted", showNotWantedToJoin),
                _buildFilterChip(context, "Expired", showExpired),
              ],
            ),
          ],
        ),
      ),
    );
  }

// FilterChip builder aligned to blue-centric palette
  Widget _buildFilterChip(BuildContext context, String label, bool selected) {
    IconData icon;
    Color activeColor;
    Color inactiveColor;

    switch (label) {
      case 'Accepted':
        icon = Icons.check_circle;
        activeColor = AppColors.primaryDark;
        inactiveColor = AppColors.primary.withOpacity(0.2);
        break;
      case 'Pending':
        icon = Icons.hourglass_empty;
        activeColor = AppColors.secondaryDark;
        inactiveColor = AppColors.secondary.withOpacity(0.2);
        break;
      case 'NotAccepted':
        icon = Icons.cancel;
        activeColor = AppDarkColors.error;
        inactiveColor = AppDarkColors.error.withOpacity(0.2);
        break;
      case 'New Users':
        icon = Icons.group_add;
        activeColor = AppColors.primary;
        inactiveColor = AppColors.primaryLight.withOpacity(0.2);
        break;
      case 'Expired':
        icon = Icons.schedule;
        activeColor = AppColors.surface;
        inactiveColor = AppColors.surface.withOpacity(0.2);
        break;
      default:
        icon = Icons.label;
        activeColor = Theme.of(context).colorScheme.primary.withOpacity(0.8);
        inactiveColor = Theme.of(context).disabledColor.withOpacity(0.2);
    }

    return FilterChip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      selected: selected,
      backgroundColor: inactiveColor,
      selectedColor: activeColor,
      onSelected: (bool isSelected) {
        onFilterChange(label, isSelected);
      },
    );
  }
}
