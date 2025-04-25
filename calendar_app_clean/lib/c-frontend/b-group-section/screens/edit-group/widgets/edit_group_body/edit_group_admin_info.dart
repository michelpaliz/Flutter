// lib/c-frontend/b-group-section/screens/edit-group/edit_group_admin_info.dart
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/selected_users/admin_info_card.dart';
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
