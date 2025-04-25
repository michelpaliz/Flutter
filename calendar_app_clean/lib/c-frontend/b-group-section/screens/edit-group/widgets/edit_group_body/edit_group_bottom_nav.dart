// lib/c-frontend/b-group-section/screens/edit-group/edit_group_bottom_nav.dart
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/group/bottom_nav.dart';
import 'package:flutter/material.dart';

class EditGroupBottomNav extends StatelessWidget {
  final VoidCallback onUpdate;

  const EditGroupBottomNav({Key? key, required this.onUpdate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationSection(onGroupUpdate: onUpdate);
  }
}
