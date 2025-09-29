import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/a-models/notification_model/userInvitation_status.dart';
import 'package:hexora/d-stateManagement/user/user_management.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  final Map<String, UserInviteStatus> filteredUsers;
  final Map<String, String?> usersRoles;
  final UserManagement userManagement;
  final Widget Function(String, User, String) buildUserTile;

  UserList({
    required this.filteredUsers,
    required this.usersRoles,
    required this.userManagement,
    required this.buildUserTile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: filteredUsers.entries.isNotEmpty
          ? filteredUsers.entries.map((entry) {
              final String userName = entry.key;
              final UserInviteStatus userInviteStatus = entry.value;

              return FutureBuilder<User?>(
                future: userManagement.userService.getUserByUsername(userName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final user = snapshot.data!;
                    final roleValue =
                        usersRoles[userName] ?? userInviteStatus.role;

                    return buildUserTile(userName, user, roleValue);
                  } else {
                    return Text('User not found');
                  }
                },
              );
            }).toList()
          : [Text("No user roles available")],
    );
  }
}
