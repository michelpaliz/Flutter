//** UI for my view */

import 'package:first_project/enums/routes/routes.dart';
import 'package:first_project/l10n/l10n.dart';
import 'package:first_project/models/event.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/firestore_database/logic_backend/firestore_service.dart';
import 'package:first_project/views/event-logic/add_event.dart';
import 'package:first_project/views/event-logic/edit_event.dart';
import 'package:first_project/views/event-logic/event_detail.dart';
import 'package:first_project/views/group-functions/calendar-group/group_details.dart';
import 'package:first_project/views/group-functions/calendar-group/group_settings.dart';
import 'package:first_project/views/group-functions/create_group_data.dart';
import 'package:first_project/views/group-functions/edit_group_data.dart';
import 'package:first_project/views/group-functions/show_groups.dart';
import 'package:first_project/views/log-user/login_view.dart';
import 'package:first_project/views/log-user/recover_password.dart';
import 'package:first_project/views/log-user/register_view.dart';
import 'package:first_project/views/log-user/verify_email_view.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/stateManangement/theme_preference_provider.dart';
import 'package:first_project/views/settings.dart';
import 'package:first_project/views/show_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'dart:developer' as devtools show log;

class MyApp extends StatefulWidget {
  final User? currentUser;

  const MyApp({Key? key, required this.currentUser}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Group> fetchedGroups;

  late bool isLogged;

  @override
  void initState() {
    super.initState();
    // Fetch user groups asynchronously in the initState
    isLogged = widget.currentUser == null ? false : true;
    loadData();
  }

  Future<void> loadData() async {
    final providerManagement =
        Provider.of<ProviderManagement>(context, listen: false);
    final FirestoreService storeService =
        Provider.of<FirestoreService>(context, listen: false);

    try {
      List<Group>? groups =
          await storeService.fetchUserGroups(widget.currentUser?.groupIds);
      providerManagement.setGroups = groups;
      setState(() {
        fetchedGroups = groups;
      });
    } catch (error) {
      print('Error fetching user groups: $error');
    }
  }

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
              settings: (context) => const Settings(),
              // loginRoute: (context) => LoginView(onLoginSuccess: (user) {
              //       // AppInitializer.goToMain(context, user);
              //     }),
              loginRoute: (context) => LoginView(),
              registerRoute: (context) => const RegisterView(),
              passwordRecoveryRoute: (context) => PasswordRecoveryScreen(),
              userCalendar: (context) => const NotesView(),
              verifyEmailRoute: (context) => const VerifyEmailView(),
              editEvent: (context) {
                final event =
                    ModalRoute.of(context)?.settings.arguments as Event?;
                if (event != null) {
                  return EditNoteScreen(event: event);
                }
                return SizedBox
                    .shrink(); // Return an empty widget or handle the error
              },
              showGroups: (context) => ShowGroups(),
              createGroupData: (context) => CreateGroupData(),
              showNotifications: (context) => ShowNotifications(),
              groupSettings: (context) {
                final group =
                    ModalRoute.of(context)?.settings.arguments as Group?;
                if (group != null) {
                  return GroupSettings(group: group);
                }
                // Handle the case when no group is passed
                return SizedBox
                    .shrink(); // Return an empty widget or handle the error
              },
              editGroup: (context) {
                final group =
                    ModalRoute.of(context)?.settings.arguments as Group?;
                if (group != null) {
                  return EditGroupData(group: group);
                }
                // Handle the case when no group is passed
                return SizedBox
                    .shrink(); // Return an empty widget or handle the error
              },
              groupCalendar: (context) {
                final group =
                    ModalRoute.of(context)?.settings.arguments as Group?;
                if (group != null) {
                  return GroupDetails(group: group);
                }
                // Handle the case when no group is passed
                return SizedBox
                    .shrink(); // Return an empty widget or handle the error
              },
              addEvent: (context) {
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
              eventDetail: (context) {
                final event =
                    ModalRoute.of(context)?.settings.arguments as Event?;
                if (event != null) {
                  return EventDetail(event: event);
                }
                return SizedBox
                    .shrink(); // Return an empty widget or handle the error
              },
              editGroupData: (context) {
                final group =
                    ModalRoute.of(context)?.settings.arguments as Group?;
                if (group != null) {
                  return EditGroupData(group: group);
                }
                return SizedBox
                    .shrink(); // Return an empty widget or handle the error
              }
            },

            home: isLogged == true
                ? ShowGroups()
                : LoginView(
                    // onLoginSuccess: (user) async {
                    //   devtools.log(
                    //       'This is the register user from the login $user');
                    //   await AppInitializer.goToMain(context, user);
                    // },
                    ));
      },
    );
  }
}
