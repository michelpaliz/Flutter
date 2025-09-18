import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final bool showAccepted;
  final bool showPending;
  final bool showNotWantedToJoin;

  /// Callback still uses stable tokens:
  /// 'Accepted' | 'Pending' | 'NotAccepted'
  final void Function(String token, bool selected) onFilterChange;

  /// Localized labels
  final String acceptedText;
  final String pendingText;
  final String notAcceptedText;

  /// Optional per-chip accent colors (defaults are Tailwind-ish)
  final Color acceptedColor;
  final Color pendingColor;
  final Color notAcceptedColor;

  const FilterChips({
    super.key,
    required this.showAccepted,
    required this.showPending,
    required this.showNotWantedToJoin,
    required this.onFilterChange,
    required this.acceptedText,
    required this.pendingText,
    required this.notAcceptedText,
    this.acceptedColor = const Color(0xFF16A34A), // green-600
    this.pendingColor = const Color(0xFFB45309), // amber-700
    this.notAcceptedColor = const Color(0xFFDC2626), // red-600
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(
          context: context,
          label: acceptedText,
          selected: showAccepted,
          baseColor: acceptedColor,
          onSelected: (v) => onFilterChange('Accepted', v),
        ),
        _buildChip(
          context: context,
          label: pendingText,
          selected: showPending,
          baseColor: pendingColor,
          onSelected: (v) => onFilterChange('Pending', v),
        ),
        _buildChip(
          context: context,
          label: notAcceptedText,
          selected: showNotWantedToJoin,
          baseColor: notAcceptedColor,
          onSelected: (v) => onFilterChange('NotAccepted', v),
        ),
      ],
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool selected,
    required Color baseColor,
    required ValueChanged<bool> onSelected,
  }) {
    final cs = Theme.of(context).colorScheme;

    // Selected: filled with the base color, label uses contrasting text.
    // Unselected: subtle container, label takes base color as accent.
    final bgSelected = baseColor;
    final fgSelected = _onColor(bgSelected);
    final bgUnselected = cs.surfaceVariant.withOpacity(0.6);
    final borderUnselected = cs.outlineVariant;
    final fgUnselected = baseColor;

    final chipTheme = ChipTheme.of(context).copyWith(
      backgroundColor: selected ? bgSelected : bgUnselected,
      selectedColor: bgSelected, // for older chip theming paths
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected ? fgSelected : fgUnselected,
            fontWeight: FontWeight.w600,
          ),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? Colors.transparent : borderUnselected,
        ),
      ),
    );

    return ChipTheme(
      data: chipTheme,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        showCheckmark: false,
        // Small visual feedback on press/hover
        pressElevation: 0,
      ),
    );
  }

  Color _onColor(Color background) {
    final brightness = ThemeData.estimateBrightnessForColor(background);
    return (brightness == Brightness.dark) ? Colors.white : Colors.black;
  }
}
