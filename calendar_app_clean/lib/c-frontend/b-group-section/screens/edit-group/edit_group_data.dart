import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/edit_group_body/edit_group_body.dart';

class EditGroupData extends StatefulWidget {
  final Group group;
  final List<User> users;

  const EditGroupData({required this.group, required this.users, Key? key})
      : super(key: key);

  @override
  _EditGroupDataState createState() => _EditGroupDataState();
}

class _EditGroupDataState extends State<EditGroupData> {
  late UserManagement? _userManagement;
  late GroupManagement _groupManagement;
  late NotificationManagement _notificationManagement;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
    _notificationManagement =
        Provider.of<NotificationManagement>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return EditGroupBody(
      group: widget.group,
      users: widget.users,
      userManagement: _userManagement!,
      groupManagement: _groupManagement,
      notificationManagement: _notificationManagement,
    );
  }
}
