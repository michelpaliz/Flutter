import 'package:first_project/enums/routes/appRoutes.dart';
import 'package:first_project/l10n/l10n.dart';
import 'package:first_project/models/event.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/views/event-logic/add_event.dart';
import 'package:first_project/views/event-logic/edit_event.dart';
import 'package:first_project/views/event-logic/event_detail.dart';
import 'package:first_project/views/group-functions/calendar-group/group_details.dart';
import 'package:first_project/views/group-functions/calendar-group/group_settings.dart';
import 'package:first_project/views/group-functions/create_group_data.dart';
import 'package:first_project/views/group-functions/edit_group_data.dart';
import 'package:first_project/views/group-functions/show_groups.dart';
import 'package:first_project/views/home_page.dart';
import 'package:first_project/views/log-user/login_view.dart';
import 'package:first_project/views/log-user/recover_password.dart';
import 'package:first_project/views/log-user/register_view.dart';
import 'package:first_project/views/log-user/verify_email_view.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:first_project/views/settings.dart';
import 'package:first_project/views/show_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// Import other necessary files and packages

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProviderManagement(user: null), // Initialize ProviderManagement here
      child: MaterialApp(
        theme: ThemeData(
            // Define your theme here
            ),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: L10n.all,
        home: RegisterView(), // Display the RegisterView as the initial route
        routes: {
          AppRoutes.homePage: (context) => HomePage(),
          AppRoutes.loginRoute: (context) => LoginView(),
          AppRoutes.registerRoute: (context) => const RegisterView(),
          AppRoutes.verifyEmailRoute: (context) => const VerifyEmailView(),
          AppRoutes.settings: (context) => const Settings(),
          AppRoutes.passwordRecoveryRoute: (context) =>
              PasswordRecoveryScreen(),
          AppRoutes.userCalendar: (context) => const NotesView(),
          AppRoutes.editEvent: (context) {
            final event = ModalRoute.of(context)?.settings.arguments as Event?;
            if (event != null) {
              return EditNoteScreen(event: event);
            }
            return SizedBox
                .shrink(); // Return an empty widget or handle the error
          },
          AppRoutes.showGroups: (context) => ShowGroups(),
          AppRoutes.createGroupData: (context) => CreateGroupData(),
          AppRoutes.showNotifications: (context) => ShowNotifications(),
          AppRoutes.groupSettings: (context) {
            final group = ModalRoute.of(context)?.settings.arguments as Group?;
            if (group != null) {
              return GroupSettings(group: group);
            }
            // Handle the case when no group is passed
            return SizedBox
                .shrink(); // Return an empty widget or handle the error
          },
          AppRoutes.editGroup: (context) {
            final group = ModalRoute.of(context)?.settings.arguments as Group?;
            if (group != null) {
              return EditGroupData(group: group);
            }
            // Handle the case when no group is passed
            return SizedBox
                .shrink(); // Return an empty widget or handle the error
          },
          AppRoutes.groupCalendar: (context) {
            final group = ModalRoute.of(context)?.settings.arguments as Group?;
            if (group != null) {
              return GroupDetails(group: group);
            }
            // Handle the case when no group is passed
            return SizedBox
                .shrink(); // Return an empty widget or handle the error
          },
          AppRoutes.addEvent: (context) {
            final dynamic arg = ModalRoute.of(context)?.settings.arguments;

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
            if (event != null) {
              return EventDetail(event: event);
            }
            return SizedBox
                .shrink(); // Return an empty widget or handle the error
          },
          AppRoutes.editGroupData: (context) {
            final group = ModalRoute.of(context)?.settings.arguments as Group?;
            if (group != null) {
              return EditGroupData(group: group);
            }
            return SizedBox.shrink();
          },
          
        },
      ),
    );
  }
}
