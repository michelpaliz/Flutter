// routes.dart

import 'package:calendar_app_frontend/a-models/group_model/event/event.dart';
import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/a-home-section/home_page.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/create-group/search-bar/screens/create_group_data.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/edit-group/edit_group_data.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/edit-group/widgets/utils/edit_group_arg.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/group-settings/group_settings.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/calendar/calendar_main_view/main_calendar_view.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/show-groups/show_groups.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/add_screen/add_event/UI/add_event_screen.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/actions/edit_screen/UI/edit_event_screen.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/event_screen/event_detail.dart';
import 'package:calendar_app_frontend/c-frontend/d-log-user-section/login/login_view.dart';
import 'package:calendar_app_frontend/c-frontend/d-log-user-section/recover_password.dart';
import 'package:calendar_app_frontend/c-frontend/d-log-user-section/register/register_view.dart';
import 'package:calendar_app_frontend/c-frontend/d-log-user-section/verify_email_view.dart';
import 'package:calendar_app_frontend/c-frontend/e-notification-section/show-notifications/show_notifications.dart';
import 'package:calendar_app_frontend/c-frontend/f-settings-section/settings.dart';
import 'package:calendar_app_frontend/c-frontend/routes/appRoutes.dart';
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
  AppRoutes.groupCalendar: (context) {
    final group = ModalRoute.of(context)?.settings.arguments as Group?;
    if (group == null) return const SizedBox.shrink();
    return MainCalendarView(group: group);
  },
  AppRoutes.addEvent: (context) {
    final group = ModalRoute.of(context)!.settings.arguments as Group?;
    if (group == null) return const SizedBox.shrink();
    return AddEventScreen(group: group);
  },
  AppRoutes.eventDetail: (context) {
    final event = ModalRoute.of(context)?.settings.arguments as Event?;
    return event != null ? EventDetail(event: event) : SizedBox.shrink();
  },
  AppRoutes.editGroupData: (context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as EditGroupArguments;
    return EditGroupData(group: args.group, users: args.users);
  },
  AppRoutes.homePage: (context) => HomePage(),
  AppRoutes.groupSettings: (context) {
    final group = ModalRoute.of(context)?.settings.arguments as Group?;
    return group != null ? GroupSettings(group: group) : SizedBox.shrink();
  },
};
