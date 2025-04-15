import 'package:flutter/material.dart';
import 'package:first_project/a-models/user_model/user.dart';

class UserDropdown extends StatelessWidget {
  final List<User> users;
  final User? selectedUser;
  final Function(User) onUserSelected;

  const UserDropdown({
    Key? key,
    required this.users,
    required this.selectedUser,
    required this.onUserSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<User>(
      value: selectedUser,
      onChanged: (User? user) {
        if (user != null) onUserSelected(user);
      },
      items: users.map((user) {
        return DropdownMenuItem<User>(
          value: user,
          child: Text(user.name),
        );
      }).toList(),
      decoration: const InputDecoration(labelText: 'Select User'),
    );
  }
}
