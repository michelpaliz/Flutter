import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/utils/selected_users/admin_info_card.dart';

class AdminInfoSection extends StatelessWidget {
  final User currentUser;

  const AdminInfoSection({Key? key, required this.currentUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminInfoCard(currentUser: currentUser);
  }
}
