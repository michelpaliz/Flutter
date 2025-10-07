// routes.dart

import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/event/event.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/c-frontend/a-home-section/home_page.dart';
import 'package:hexora/c-frontend/b-dashboard-section/dashboard_screen/group_dashboard.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/graphs/group_insights_screen.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/members/group_members_screen.dart';
import 'package:hexora/c-frontend/b-dashboard-section/sections/services_clients/services_clients_screen.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/calendar/calendar_main_view/screen/main_calendar_view.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/create-group/search-bar/screens/create_group_data.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/edit-group/edit_group_data.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/edit-group/widgets/utils/edit_group_arg.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/group-settings/group_settings.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/show-groups/group_screen/group_section.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/add_screen/add_event/UI/add_event_screen.dart';
import 'package:hexora/c-frontend/d-event-section/screens/actions/edit_screen/UI/edit_event_screen.dart';
import 'package:hexora/c-frontend/d-event-section/screens/event_screen/event_detail.dart';
import 'package:hexora/c-frontend/e-log-user-section/forgot_password.dart';
import 'package:hexora/c-frontend/e-log-user-section/login/login_view.dart';
import 'package:hexora/c-frontend/e-log-user-section/register/ui/register_view.dart';
import 'package:hexora/c-frontend/e-log-user-section/verify_email_view.dart';
import 'package:hexora/c-frontend/f-notification-section/show-notifications/show_notifications.dart';
import 'package:hexora/c-frontend/g-agenda-section/agenda_screen.dart';
import 'package:hexora/c-frontend/h-profile-section/edit/profile_edit_screen.dart';
import 'package:hexora/c-frontend/h-profile-section/view/profile_view_screen.dart';
import 'package:hexora/c-frontend/i-settings-section/screens/settings.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:provider/provider.dart';

final Map<String, WidgetBuilder> routes = {
  AppRoutes.settings: (context) => const Settings(),
  AppRoutes.loginRoute: (context) => LoginView(),
  AppRoutes.registerRoute: (context) => const RegisterView(),
  AppRoutes.passwordRecoveryRoute: (context) => ForgotPasswordForm(),
  AppRoutes.verifyEmailRoute: (context) => const VerifyEmailView(),
  AppRoutes.groupDashboard: (context) {
    final group = ModalRoute.of(context)?.settings.arguments as Group?;
    if (group == null) return const SizedBox.shrink();
    return GroupDashboard(group: group);
  },

  AppRoutes.groupInsights: (context) {
    final group = ModalRoute.of(context)?.settings.arguments as Group?;
    if (group == null) return const SizedBox.shrink();
    return GroupInsightsScreen(group: group);
  },

  AppRoutes.editEvent: (context) {
    final event = ModalRoute.of(context)?.settings.arguments as Event?;
    return event != null ? EditEventScreen(event: event) : SizedBox.shrink();
  },
  AppRoutes.showGroups: (context) => GroupListSection(),
  AppRoutes.createGroupData: (context) => CreateGroupData(),
  AppRoutes.showNotifications: (context) {
    final user = ModalRoute.of(context)?.settings.arguments as User?;
    return user != null ? ShowNotifications(user: user) : SizedBox.shrink();
  },
  AppRoutes.groupCalendar: (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final gm = context.read<GroupDomain>();

    // 1) Full Group passed in → use immediately
    if (args is Group) {
      gm.currentGroup = args;
      return MainCalendarView(group: args);
    }

    // 2) groupId (String) passed in → try cache, else fetch via repository
    if (args is String && args.isNotEmpty) {
      // Try cached group first
      Group? cached;
      try {
        cached = gm.groups.firstWhere((g) => g.id == args);
      } catch (_) {
        cached = null;
      }

      if (cached != null) {
        gm.currentGroup = cached;
        return MainCalendarView(group: cached);
      }

      // Not cached → fetch
      return FutureBuilder<Group>(
        future: gm.groupRepository.getGroupById(args),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError || !snap.hasData) {
            return const Scaffold(
              body: Center(child: Text('Could not load group')),
            );
          }

          final group = snap.data!;
          gm.currentGroup = group;
          return MainCalendarView(group: group);
        },
      );
    }

    // 3) Fallback for bad arguments
    return const Scaffold(
      body: Center(child: Text('Invalid group argument')),
    );
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
  AppRoutes.groupServicesClients: (context) {
    final group = ModalRoute.of(context)?.settings.arguments as Group?;
    if (group == null) return const SizedBox.shrink();
    return ServicesClientsScreen(group: group);
  },
  AppRoutes.agenda: (_) => const AgendaScreen(),

  // NEW: Profile details (read-only / pretty view)
  AppRoutes.profileDetails: (_) => const ProfileViewScreen(),

  // Existing edit profile screen
  AppRoutes.profile: (_) => const ProfileEditScreen(),

  AppRoutes.groupMembers: (context) {
    final group = ModalRoute.of(context)?.settings.arguments as Group?;
    if (group == null) return const SizedBox.shrink();
    return GroupMembersScreen(group: group);
  }
};
