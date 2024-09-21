import 'package:first_project/a-models/user.dart';
import 'package:first_project/utilities/utilities.dart';
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
          title: Text('Admin: ${currentUser!.userName}'),
          subtitle: Text('Role: Administrator'),
          leading: CircleAvatar(
            backgroundImage: Utilities.buildProfileImage(currentUser!.photoUrl),
          ),
        ),
      ),
    );
  }
}
