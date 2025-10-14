import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/f-themes/app_colors/palette/app_colors.dart';
import 'package:hexora/f-themes/app_colors/tools_colors/theme_colors.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AdminWithFiltersSection extends StatelessWidget {
  final User currentUser;
  final bool showAccepted;
  final bool showPending;
  final bool showNotWantedToJoin;
  final bool showNewUsers;
  final bool showExpired;

  /// Accepts either a localized label String or any key/enum (parent resolves).
  final void Function(dynamic filter, bool isSelected) onFilterChange;

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
    final loc = AppLocalizations.of(context)!;

    // Get dynamic background for the container
    final Color containerBg = ThemeColors.getContainerBackgroundColor(context);
    // Contrast text/icon color based on that bg
    final Color contrastText = ThemeColors.getContrastTextColor(
      context,
      containerBg,
    );

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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: contrastText),
                    ),
                    Text(
                      loc.administrator, // ✅ localized
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
                _buildFilterChip(
                  context,
                  keyId: 'newUsers',
                  label: loc.newUsers, // ✅ localized
                  selected: showNewUsers,
                ),
                _buildFilterChip(
                  context,
                  keyId: 'pending',
                  label: loc.pending, // ✅ localized
                  selected: showPending,
                ),
                _buildFilterChip(
                  context,
                  keyId: 'accepted',
                  label: loc.accepted, // ✅ localized
                  selected: showAccepted,
                ),
                _buildFilterChip(
                  context,
                  keyId: 'notAccepted',
                  label: loc.notAccepted, // ✅ localized
                  selected: showNotWantedToJoin,
                ),
                _buildFilterChip(
                  context,
                  keyId: 'expired',
                  label: loc.expired, // ✅ localized
                  selected: showExpired,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // FilterChip builder: use a stable keyId for icon/colors, and a localized label for display.
  Widget _buildFilterChip(
    BuildContext context, {
    required String keyId,
    required String label,
    required bool selected,
  }) {
    IconData icon;
    Color activeColor;
    Color inactiveColor;

    switch (keyId) {
      case 'accepted':
        icon = Icons.check_circle;
        activeColor = const Color.fromARGB(255, 34, 210, 25);
        inactiveColor = AppColors.primary.withOpacity(0.2);
        break;
      case 'pending':
        icon = Icons.hourglass_empty;
        activeColor = const Color.fromARGB(255, 33, 106, 146);
        inactiveColor = AppColors.secondary.withOpacity(0.2);
        break;
      case 'notAccepted':
        icon = Icons.cancel;
        activeColor = AppDarkColors.error;
        inactiveColor = AppDarkColors.error.withOpacity(0.2);
        break;
      case 'newUsers':
        icon = Icons.group_add;
        activeColor = const Color.fromARGB(255, 136, 150, 11);
        inactiveColor = AppColors.primaryLight.withOpacity(0.2);
        break;
      case 'expired':
        icon = Icons.schedule;
        activeColor = const Color.fromARGB(255, 188, 30, 212);
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
        // Pass the localized label (parent resolves), or swap to keyId/enum if you prefer.
        onFilterChange(label, isSelected);
      },
    );
  }
}
