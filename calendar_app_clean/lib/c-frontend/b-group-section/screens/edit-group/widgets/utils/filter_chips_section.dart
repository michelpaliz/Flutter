import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

class FilterChipsSection extends StatelessWidget {
  final bool showAccepted;
  final bool showPending;
  final bool showNotWantedToJoin;
  final bool showNewUsers;
  final bool showExpired; // ✅ Add this

  final void Function(String filter, bool isSelected) onFilterChange;

  const FilterChipsSection({
    Key? key,
    required this.showAccepted,
    required this.showPending,
    required this.showNotWantedToJoin,
    required this.showNewUsers,
    required this.showExpired, // ✅ Include here
    required this.onFilterChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildAnimatedChip(
          context: context,
          label: "Accepted",
          icon: Icons.check_circle,
          selected: showAccepted,
          selectedColor: Colors.green.shade100,
          iconColor: Colors.green,
          onSelected: (val) => onFilterChange("Accepted", val),
        ),
        _buildAnimatedChip(
          context: context,
          label: "Pending",
          icon: Icons.hourglass_bottom,
          selected: showPending,
          selectedColor: Colors.orange.shade100,
          iconColor: Colors.orange,
          onSelected: (val) => onFilterChange("Pending", val),
        ),
        _buildAnimatedChip(
          context: context,
          label: "NotAccepted",
          icon: Icons.cancel,
          selected: showNotWantedToJoin,
          selectedColor: Colors.red.shade100,
          iconColor: Colors.red,
          onSelected: (val) => onFilterChange("NotAccepted", val),
        ),
        _buildAnimatedChip(
          context: context,
          label: "New Users",
          icon: Icons.person_add_alt_1,
          selected: showNewUsers,
          selectedColor: Colors.blue.shade100,
          iconColor: Colors.blue,
          onSelected: (val) => onFilterChange("New Users", val),
        ),
        _buildAnimatedChip(
          context: context,
          label: "Expired", // ✅ NEW
          icon: Icons.schedule, // ⏳ or any other icon you prefer
          selected: showExpired,
          selectedColor: Colors.grey.shade300,
          iconColor: Colors.grey,
          onSelected: (val) => onFilterChange("Expired", val),
        ),
      ],
    );
  }

  Widget _buildAnimatedChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required Color selectedColor,
    required Color iconColor,
    required void Function(bool) onSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        boxShadow: selected
            ? [
                BoxShadow(
                  color: ThemeColors.getFilterChipGlowColor(context, iconColor),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: FilterChip(
        avatar: Icon(icon, size: 18, color: iconColor),
        label: Text(label),
        selected: selected,
        selectedColor: selectedColor,
        onSelected: onSelected,
      ),
    );
  }
}
