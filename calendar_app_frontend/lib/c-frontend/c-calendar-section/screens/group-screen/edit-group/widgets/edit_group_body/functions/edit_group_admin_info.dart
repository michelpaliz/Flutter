// lib/c-frontend/b-group-section/screens/edit-group/edit_group_admin_info.dart
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/c-calendar-section/utils/selected_users/admin_info_card.dart';
import 'package:flutter/material.dart';

class EditGroupAdminInfo extends StatelessWidget {
  final User currentUser;

  const EditGroupAdminInfo({Key? key, required this.currentUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminInfoCard(currentUser: currentUser);
  }
}
