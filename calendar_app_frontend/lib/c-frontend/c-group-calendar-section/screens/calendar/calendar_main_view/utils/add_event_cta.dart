// lib/.../calendar/widgets/add_event_cta.dart
import 'package:flutter/material.dart';

class AddEventCta extends StatelessWidget {
  final VoidCallback onPressed;
  const AddEventCta({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Event'),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
