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
import 'list_group_controller.dart';
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
  bool _hasFetchedGroups = false;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
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
    final currentUserNotifier =
        Provider.of<UserManagement>(context).currentUserNotifier;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: ValueListenableBuilder<User?>(
        valueListenable: currentUserNotifier,
        builder: (context, user, _) {
          debugPrint('📡 ValueListenableBuilder user: $user');

          if (user == null) {
            debugPrint('⏳ Waiting for user...');
            return const Center(child: CircularProgressIndicator());
          }

          // ✅ Only run once
          if (!_hasFetchedGroups) {
            debugPrint("🚀 Fetching groups for user ID: ${user.id}");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GroupController.fetchGroups(user, _groupManagement);
            });
            _hasFetchedGroups = true;
          }

          return buildBody(
            context,
            _scrollDirection,
            _toggleScrollDirection,
            user,
            _userManagement!,
            _groupManagement,
            (String? role) => _currentRole = role,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: const Icon(Icons.group_add_rounded),
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
