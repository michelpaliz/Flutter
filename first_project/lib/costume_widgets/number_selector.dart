import 'package:flutter/material.dart';

class NumberSelector extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  final int minValue; // Minimum allowed value
  final int maxValue; // Maximum allowed value

  NumberSelector({
    this.value,
    required this.onChanged,
    this.minValue = 0, // Set your minimum value
    this.maxValue = 100, // Set your maximum value
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          iconSize: 14,
          onPressed: () {
            if (value != null && value! > minValue) {
              onChanged(value! - 1);
            }
          },
        ),
        Text(
          value != null ? value.toString() : '0',
          style: TextStyle(fontSize: 14),
        ),
        IconButton(
          icon: Icon(Icons.add),
          iconSize: 14,
          onPressed: () {
            if (value != null && value! < maxValue) {
              onChanged(value! + 1);
            } else {
              onChanged(maxValue); // Limit to the maximum value
            }
          },
        ),
      ],
    );
  }
}
