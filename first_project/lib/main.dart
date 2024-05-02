import 'dart:developer' as devtools show log;

import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/enums/routes/appRoutes.dart';
import 'package:first_project/l10n/l10n.dart';
import 'package:first_project/services/auth/logic_backend/auth_service.dart';
import 'package:first_project/services/firestore_database/logic_backend/firestore_service.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/stateManangement/theme_preference_provider.dart';
import 'package:first_project/styles/themes/theme_provider.dart';
import 'package:first_project/utilities/utilities.dart';
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
import 'package:first_project/models/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
//** Logic for my view */
// main.dart
import 'package:provider/provider.dart';

import 'models/group.dart';
import 'models/user.dart';
// ...

var themePreferenceProvider, storeService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  final authService = AuthService.firebase();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: authService.generateUserCustomModel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<ProviderManagement>.value(
                value: ProviderManagement(
                  user: user,
                ),
              ),
              ChangeNotifierProvider<ThemePreferenceProvider>.value(
                value: ThemePreferenceProvider(),
              ),
              // Add other providers as needed
            ],
            child: App(),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          return LoginView();
        }
      },
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemePreferenceProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: themeProvider.themeData,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: L10n.all,
          routes: {
            AppRoutes.settings: (context) => const Settings(),
            AppRoutes.loginRoute: (context) => LoginView(),
            AppRoutes.registerRoute: (context) => const RegisterView(),
            AppRoutes.passwordRecoveryRoute: (context) =>
                PasswordRecoveryScreen(),
            AppRoutes.userCalendar: (context) => const NotesView(),
            AppRoutes.verifyEmailRoute: (context) => const VerifyEmailView(),
            AppRoutes.editEvent: (context) {
              final event =
                  ModalRoute.of(context)?.settings.arguments as Event?;
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
              final group =
                  ModalRoute.of(context)?.settings.arguments as Group?;
              if (group != null) {
                return GroupSettings(group: group);
              }
              // Handle the case when no group is passed
              return SizedBox
                  .shrink(); // Return an empty widget or handle the error
            },
            AppRoutes.editGroup: (context) {
              final group =
                  ModalRoute.of(context)?.settings.arguments as Group?;
              if (group != null) {
                return EditGroupData(group: group);
              }
              // Handle the case when no group is passed
              return SizedBox
                  .shrink(); // Return an empty widget or handle the error
            },
            AppRoutes.groupCalendar: (context) {
              final group =
                  ModalRoute.of(context)?.settings.arguments as Group?;
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
              final event =
                  ModalRoute.of(context)?.settings.arguments as Event?;
              if (event != null) {
                return EventDetail(event: event);
              }
              return SizedBox
                  .shrink(); // Return an empty widget or handle the error
            },
            AppRoutes.editGroupData: (context) {
              final group =
                  ModalRoute.of(context)?.settings.arguments as Group?;
              if (group != null) {
                return EditGroupData(group: group);
              }
              return SizedBox
                  .shrink(); // Return an empty widget or handle the error
            },
            AppRoutes.homePage: (context) => HomePage(),
          },
          home: HomePage(),
        );
      },
    );
  }
}
