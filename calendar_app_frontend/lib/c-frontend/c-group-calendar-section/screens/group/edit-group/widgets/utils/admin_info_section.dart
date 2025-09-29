import 'package:flutter/material.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/utils/selected_users/admin_info_card.dart';

class AdminInfoSection extends StatelessWidget {
  final User currentUser;

  const AdminInfoSection({Key? key, required this.currentUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminInfoCard(currentUser: currentUser);
  }
}
