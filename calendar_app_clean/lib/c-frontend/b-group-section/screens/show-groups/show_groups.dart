import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../a-models/user_model/user.dart';
import '../../../../d-stateManagement/group_management.dart';
import '../../../../d-stateManagement/notification_management.dart';
import '../../../../d-stateManagement/user_management.dart';
import '../../../routes/appRoutes.dart';
import 'group_body_builder.dart';
// 👉 NEW FILES WE'LL CREATE:
import 'group_controller.dart';
import 'notification_icon.dart';

class ShowGroups extends StatefulWidget {
  const ShowGroups({super.key});

  @override
  State<ShowGroups> createState() => _ShowGroupsState();
}

class _ShowGroupsState extends State<ShowGroups> {
  User? _currentUser;
  Axis _scrollDirection = Axis.vertical;
  String? _currentRole;

  late UserManagement? _userManagement;
  late GroupManagement _groupManagement;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
    _currentUser = _userManagement!.user;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentUser != null) {
        GroupController.fetchGroups(_currentUser, _groupManagement);
      }
    });
  }

  void _createGroup() {
    Navigator.pushNamed(context, AppRoutes.createGroupData);
    setState(() {}); // Just for refresh if needed
  }

  void _toggleScrollDirection() {
    setState(() {
      _scrollDirection =
          _scrollDirection == Axis.vertical ? Axis.horizontal : Axis.vertical;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: buildBody(
        context,
        _scrollDirection,
        _toggleScrollDirection,
        _currentUser,
        _userManagement!,
        _groupManagement,
        (String? role) => _currentRole = role,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: Icon(Icons.group_add_rounded),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.groups),
      actions: [
        buildNotificationIcon(
          context: context,
          userManagement: _userManagement!,
          notificationManagement:
              Provider.of<NotificationManagement>(context, listen: false),
        ),
      ],
    );
  }
}
