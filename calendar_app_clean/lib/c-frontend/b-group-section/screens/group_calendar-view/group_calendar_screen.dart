// group_calendar_screen.dart

import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/b-backend/api/event/event_services.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/1-calendar/1.1-main_calendar_view.dart';
import 'package:first_project/c-frontend/c-event-section/utils/color_manager.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/e-drawer-style-menu/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class GroupCalendarScreen extends StatelessWidget {
  final Group group;

  const GroupCalendarScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final groupManagement = Provider.of<GroupManagement>(context);
    final userManagement = Provider.of<UserManagement>(context);
    final notificationManagement = Provider.of<NotificationManagement>(context);
    final user = userManagement.user;
    final role = group.userRoles[user?.userName ?? ''] ?? 'Member';

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.calendar)),
      drawer: MyDrawer(),
      body: MainCalendarView(
        group: group,
        eventService: EventService(),
        colorManager: ColorManager(),
        groupManagement: groupManagement,
        userManagement: userManagement,
        notificationManagement: notificationManagement,
        userRole: role,
      ),
    );
  }
}
