import 'package:flutter/material.dart';

class FilterChipsSection extends StatelessWidget {
  final bool showAccepted;
  final bool showPending;
  final bool showNotWantedToJoin;
  final void Function(String filter, bool isSelected) onFilterChange;

  const FilterChipsSection({
    Key? key,
    required this.showAccepted,
    required this.showPending,
    required this.showNotWantedToJoin,
    required this.onFilterChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: [
        FilterChip(
          label: Text("Accepted"),
          selected: showAccepted,
          onSelected: (val) => onFilterChange("Accepted", val),
        ),
        FilterChip(
          label: Text("Pending"),
          selected: showPending,
          onSelected: (val) => onFilterChange("Pending", val),
        ),
        FilterChip(
          label: Text("NotAccepted"),
          selected: showNotWantedToJoin,
          onSelected: (val) => onFilterChange("NotAccepted", val),
        ),
      ],
    );
  }
}
