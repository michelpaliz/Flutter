import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final bool showAccepted;
  final bool showPending;
  final bool showNotWantedToJoin;
  final Function(String, bool) onFilterChange;

  const FilterChips({
    required this.showAccepted,
    required this.showPending,
    required this.showNotWantedToJoin,
    required this.onFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FilterChip(
          label: Text('Accepted'),
          selected: showAccepted,
          onSelected: (selected) => onFilterChange('Accepted', selected),
        ),
        FilterChip(
          label: Text('Pending'),
          selected: showPending,
          onSelected: (selected) => onFilterChange('Pending', selected),
        ),
        FilterChip(
          label: Text('Not Accepted'),
          selected: showNotWantedToJoin,
          onSelected: (selected) => onFilterChange('NotAccepted', selected),
        ),
      ],
    );
  }
}
