import 'package:first_project/models/user.dart';
import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String userName;
  final User user;
  final String roleValue;
  final Function(String userName) onDismissed;
  final Function(String userName) onChangeRole;

  UserTile({
    required this.userName,
    required this.user,
    required this.roleValue,
    required this.onDismissed,
    required this.onChangeRole,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(userName),
      direction: roleValue.trim() != 'Administrator'
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (direction) {
        onDismissed(userName);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(userName),
        subtitle: Text(roleValue),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: user.photoUrl.isNotEmpty
              ? NetworkImage(user.photoUrl)
              : AssetImage('assets/images/default_profile.png')
                  as ImageProvider, // Default profile picture
        ),
        trailing: roleValue.trim() != 'Administrator'
            ? GestureDetector(
                onTap: () => onChangeRole(userName),
                child: Icon(Icons.settings, color: Colors.blue),
              )
            : SizedBox.shrink(),
        onTap: roleValue.trim() != 'Administrator'
            ? () => onChangeRole(userName)
            : null,
      ),
    );
  }
}
