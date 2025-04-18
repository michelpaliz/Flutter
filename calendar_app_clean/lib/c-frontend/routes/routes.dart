// routes.dart

import 'package:first_project/a-models/group_model/event_appointment/event/event.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/a-home-section/home_page.dart';
import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/screens/create_group_data.dart';
import 'package:first_project/c-frontend/b-group-section/screens/edit-group/edit_group_data.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group-settings/group_settings.dart';
import 'package:first_project/c-frontend/b-group-section/screens/group_calendar-view/group_calendar.dart';
import 'package:first_project/c-frontend/b-group-section/screens/show-groups/show_groups.dart';
import 'package:first_project/c-frontend/c-event-section/screens/add_screen/add_event.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/edit_event_screen.dart';
import 'package:first_project/c-frontend/c-event-section/screens/event_screen/event_detail.dart';
import 'package:first_project/c-frontend/d-log-user-section/login/login_view.dart';
import 'package:first_project/c-frontend/d-log-user-section/recover_password.dart';
import 'package:first_project/c-frontend/d-log-user-section/register/register_view.dart';
import 'package:first_project/c-frontend/d-log-user-section/verify_email_view.dart';
import 'package:first_project/c-frontend/e-notification-section/widgets/show_notifications.dart';
import 'package:first_project/c-frontend/routes/appRoutes.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  AppRoutes.settings: (context) => const Settings(),
  AppRoutes.loginRoute: (context) => LoginView(),
  AppRoutes.registerRoute: (context) => const RegisterView(),
  AppRoutes.passwordRecoveryRoute: (context) => PasswordRecoveryScreen(),
  AppRoutes.verifyEmailRoute: (context) => const VerifyEmailView(),
  AppRoutes.editEvent: (context) {
    final event = ModalRoute.of(context)?.settings.arguments as Event?;
    return event != null ? EditEventScreen(event: event) : SizedBox.shrink();
  },
  AppRoutes.showGroups: (context) => ShowGroups(),
  AppRoutes.createGroupData: (context) => CreateGroupData(),
  AppRoutes.showNotifications: (context) {
    final user = ModalRoute.of(context)?.settings.arguments as User?;
    return user != null ? ShowNotifications(user: user) : SizedBox.shrink();
  },
  // AppRoutes.groupSettings: (context) {
  //   final group = ModalRoute.of(context)?.settings.arguments as Group?;
  //   return group != null ? GroupSettings(group: group) : SizedBox.shrink();
  // },
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
