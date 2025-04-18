import 'package:flutter/material.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/selected_users/admin_info_card.dart';

class AdminInfoSection extends StatelessWidget {
  final User currentUser;

  const AdminInfoSection({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AdminInfoCard(currentUser: currentUser);
  }
}
