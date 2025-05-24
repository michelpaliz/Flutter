import 'package:flutter/material.dart';

/// A rounded, icon-topped button for adding a new calendar event.
class AddEventButton extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onPressed;

  const AddEventButton({
    Key? key,
    required this.isVisible,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 20),
        label: const Text("Add Event"),
        style: ElevatedButton.styleFrom(
          // New names for the old `primary` and `onPrimary`:
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,

          // If you’d rather let Material3 pick appropriate typography,
          // you can omit textStyle entirely, or choose:
          textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 16),

          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

          // Center icon+label; if you want the icon left-aligned:
          alignment: Alignment.center,

          // Control just the icon color if you need something different:
          iconColor: colorScheme.onPrimary,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}
