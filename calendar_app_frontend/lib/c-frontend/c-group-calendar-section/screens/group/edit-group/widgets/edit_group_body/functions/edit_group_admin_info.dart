// lib/c-frontend/b-group-section/screens/edit-group/edit_group_admin_info.dart
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/utils/selected_users/admin_info_card.dart';
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
