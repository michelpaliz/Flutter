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
    return Card(
      color: ThemeColors.getContainerBackgroundColor(context),
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
                  child: Icon(Icons.person),
                  backgroundColor: Colors.green.withOpacity(0.2),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser.userName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color:
                                ThemeColors.getContrastTextColorForBackground(
                                    AppColors.brown),
                          ),
                    ),
                    Text(
                      'Administrator',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                ThemeColors.getContrastTextColorForBackground(
                                    AppColors.brown),
                          ),
                    ),
                  ],
                )
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

  Widget _buildFilterChip(BuildContext context, String label, bool selected) {
    IconData icon;
    Color activeColor;
    Color inactiveColor;

    switch (label) {
      case 'Accepted':
        icon = Icons.check_circle;
        activeColor = AppColors.greenDark;
        inactiveColor = AppColors.green.withOpacity(0.2);
        break;
      case 'Pending':
        icon = Icons.hourglass_empty;
        activeColor = AppColors.yellowStrong;
        inactiveColor = AppColors.yellow.withOpacity(0.2);
        break;
      case 'NotAccepted':
        icon = Icons.cancel;
        activeColor = AppColors.redDark;
        inactiveColor = AppColors.red.withOpacity(0.2);
        break;
      case 'New Users':
        icon = Icons.group_add;
        activeColor = AppColors.blueDark;
        inactiveColor = AppColors.blue.withOpacity(0.2);
        break;
      case 'Expired':
        icon = Icons.schedule;
        activeColor = AppColors.grey;
        inactiveColor = AppColors.grey.withOpacity(0.2);
        break;
      default:
        icon = Icons.label;
        activeColor = Theme.of(context).primaryColor.withOpacity(0.8);
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
