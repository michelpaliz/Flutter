// routes.dart

import 'package:first_project/a-models/event.dart';
import 'package:first_project/a-models/group.dart';
import 'package:first_project/a-models/user.dart';
import 'package:first_project/c-frontend/a-group-section/views/create_group_data.dart';
import 'package:first_project/c-frontend/a-group-section/views/edit_group_data.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_calendar-view/group_calendar.dart';
import 'package:first_project/c-frontend/a-group-section/views/group_settings.dart';
import 'package:first_project/c-frontend/a-group-section/views/show_groups.dart';
import 'package:first_project/c-frontend/b-event-section/event_detail.dart';
import 'package:first_project/c-frontend/b-event-section/views/add_logic/add_event.dart';
import 'package:first_project/c-frontend/b-event-section/views/edit_logic/edit_event.dart';
import 'package:first_project/c-frontend/c-log-user-section/login_view.dart';
import 'package:first_project/c-frontend/c-log-user-section/recover_password.dart';
import 'package:first_project/c-frontend/c-log-user-section/register_view.dart';
import 'package:first_project/c-frontend/c-log-user-section/verify_email_view.dart';
import 'package:first_project/c-frontend/home_page.dart';
import 'package:first_project/c-frontend/notes_view.dart';
import 'package:first_project/c-frontend/settings.dart';
import 'package:first_project/c-frontend/show_notifications.dart';
import 'package:first_project/enums/routes/appRoutes.dart';
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
    return group != null ? GroupCalendar(group: group) : SizedBox.shrink();
  },
  AppRoutes.addEvent: (context) {
    final arg = ModalRoute.of(context)?.settings.arguments;

    if (arg is Group) {
      return AddEvent(
        group: arg,
      );
    } else {
      // Provide a default instance of Group if none is passed
      return AddEvent(
        group: Group.createDefaultGroup(),
      );
    }
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
