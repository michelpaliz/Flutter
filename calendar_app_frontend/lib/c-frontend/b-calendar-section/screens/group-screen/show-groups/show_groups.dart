import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../a-models/user_model/user.dart';
import '../../../../../d-stateManagement/group/group_management.dart';
import '../../../../../d-stateManagement/notification/notification_management.dart';
import '../../../../../d-stateManagement/user/user_management.dart';
import '../../../../routes/appRoutes.dart';
import 'controller/list_group_controller.dart';
import 'group_body_builder/group_body_builder.dart';
import 'utils/notification_icon.dart';

class ShowGroups extends StatefulWidget {
  const ShowGroups({super.key});

  @override
  State<ShowGroups> createState() => _ShowGroupsState();
}

class _ShowGroupsState extends State<ShowGroups> {
  Axis _scrollDirection = Axis.vertical;
  bool _hasFetchedGroups = false;
  bool _initialized = false;

  late UserManagement _userManagement;
  late GroupManagement _groupManagement;

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
  }

  void _toggleScrollDirection() {
    setState(() {
      _scrollDirection =
          _scrollDirection == Axis.vertical ? Axis.horizontal : Axis.vertical;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserNotifier = Provider.of<UserManagement>(
      context,
    ).currentUserNotifier;

    return ValueListenableBuilder<User?>(
      valueListenable: currentUserNotifier,
      builder: (context, user, _) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ Fetch groups only once
        if (!_hasFetchedGroups) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GroupController.fetchGroups(user, _groupManagement);
          });
          _hasFetchedGroups = true;
        }

        return MainScaffold(
          title: AppLocalizations.of(context)!.groups,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: AppLocalizations.of(context)!.refresh,
              onPressed: () {
                GroupController.fetchGroups(user, _groupManagement);
                setState(() {}); // refresh view
              },
            ),
            buildNotificationIcon(
              context: context,
              userManagement: _userManagement,
              notificationManagement: Provider.of<NotificationManagement>(
                context,
                listen: false,
              ),
            ),
          ],
          body: buildBody(
            context,
            _scrollDirection,
            _toggleScrollDirection,
            user,
            _userManagement,
            _groupManagement,
            (String? role) {}, // Optional callback
          ),
          fab: FloatingActionButton(
            onPressed: _createGroup,
            child: const Icon(Icons.group_add_rounded),
          ),
        );
      },
    );
  }
}
