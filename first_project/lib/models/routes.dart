// routes.dart

import 'package:first_project/enums/routes/appRoutes.dart';
import 'package:first_project/models/event.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/frontend/event-logic/edit_logic/edit_event.dart';
import 'package:first_project/frontend/event-logic/event_detail.dart';
import 'package:first_project/frontend/group-functions/group-logic/group_settings/group_details.dart';
import 'package:first_project/frontend/group-functions/group-logic/group_settings/group_settings.dart';
import 'package:first_project/frontend/event-logic/add_logic/add_event.dart';
import 'package:first_project/frontend/group-functions/group-logic/views/create_group_data.dart';
import 'package:first_project/frontend/group-functions/group-logic/views/show_groups.dart';
import 'package:first_project/frontend/group-functions/group-logic/views/edit_group_data.dart';
import 'package:first_project/frontend/home_page.dart';
import 'package:first_project/frontend/log-user/login_view.dart';
import 'package:first_project/frontend/log-user/recover_password.dart';
import 'package:first_project/frontend/log-user/register_view.dart';
import 'package:first_project/frontend/log-user/verify_email_view.dart';
import 'package:first_project/frontend/notes_view.dart';
import 'package:first_project/frontend/settings.dart';
import 'package:first_project/frontend/show_notifications.dart';

import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  AppRoutes.settings: (context) => const Settings(),
  AppRoutes.loginRoute: (context) => LoginView(),
  AppRoutes.registerRoute: (context) => const RegisterView(),
  AppRoutes.passwordRecoveryRoute: (context) => PasswordRecoveryScreen(),
  AppRoutes.userCalendar: (context) => const NotesView(),
  AppRoutes.verifyEmailRoute: (context) => const VerifyEmailView(),
  AppRoutes.editEvent: (context) {
    final event = ModalRoute.of(context)?.settings.arguments as Event?;
    return event != null ? EditNoteScreen(event: event) : SizedBox.shrink();
  },
  AppRoutes.showGroups: (context) => ShowGroups(),
  AppRoutes.createGroupData: (context) => CreateGroupData(),
  AppRoutes.showNotifications: (context) {
    final user = ModalRoute.of(context)?.settings.arguments as User?;
    return user != null ? ShowNotifications(user: user) : SizedBox.shrink();
  },
  AppRoutes.groupSettings: (context) {
    final group = ModalRoute.of(context)?.settings.arguments as Group?;
    return group != null ? GroupSettings(group: group) : SizedBox.shrink();
  },
  AppRoutes.groupCalendar: (context) {
    final group = ModalRoute.of(context)?.settings.arguments as Group?;
    return group != null ? GroupDetails(group: group) : SizedBox.shrink();
  },
  AppRoutes.addEvent: (context) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    User? user;
    Group? group;

    if (arg is User) {
      user = arg;
    } else if (arg is Group) {
      group = arg;
    }

    return EventNoteWidget(user: user, group: group);
  },
  AppRoutes.eventDetail: (context) {
    final event = ModalRoute.of(context)?.settings.arguments as Event?;
    return event != null ? EventDetail(event: event) : SizedBox.shrink();
  },
  AppRoutes.editGroupData: (context) {
    final args = ModalRoute.of(context)?.settings.arguments as EditGroupData;
    return EditGroupData(group: args.group, users: args.users);
  },
  AppRoutes.homePage: (context) => HomePage(),
};
