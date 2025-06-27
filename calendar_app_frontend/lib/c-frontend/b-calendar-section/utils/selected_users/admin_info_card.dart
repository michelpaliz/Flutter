import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/f-themes/utilities/utilities.dart';
import 'package:flutter/material.dart';

class AdminInfoCard extends StatelessWidget {
  final User? currentUser;

  const AdminInfoCard({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 5,
        child: ListTile(
          title: Text(
            '${currentUser!.userName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Administrator'),
          leading: CircleAvatar(
            backgroundImage: Utilities.buildProfileImage(
              currentUser!.photoUrl ?? "",
            ),
          ),
        ),
      ),
    );
  }
}
