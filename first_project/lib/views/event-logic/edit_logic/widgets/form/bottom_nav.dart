import 'package:flutter/material.dart';

class BottomNavigationSection extends StatelessWidget {
  final VoidCallback onGroupUpdate;

  const BottomNavigationSection({
    required this.onGroupUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: onGroupUpdate,
        icon: Icon(Icons.group_add_rounded),
        label: Text('Edit'),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
          onPrimary: Colors.white,
        ),
      ),
    );
  }
}
