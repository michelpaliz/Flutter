import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:flutter/material.dart';

class AddPeopleSection extends StatelessWidget {
  final User? currentUser;
  final Group group;
  final Function(List<User> updatedUsers, Map<String, String> updatedRoles)
      onDataChanged;

  const AddPeopleSection({
    Key? key,
    required this.currentUser,
    required this.group,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AddPeopleSection(
      currentUser: currentUser,
      group: group,
      onDataChanged: onDataChanged,
    );
  }
}
