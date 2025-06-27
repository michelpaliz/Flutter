// lib/c-frontend/b-group-section/screens/edit-group/edit_group_bottom_nav.dart

import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/edit-group/widgets/form/bottom_nav_bar.dart';
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
