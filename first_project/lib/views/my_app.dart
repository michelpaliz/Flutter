//** UI for my view */

import 'package:first_project/enums/routes/routes.dart';
import 'package:first_project/main.dart';
import 'package:first_project/models/event.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/views/event-logic/add_event.dart';
import 'package:first_project/views/event-logic/edit_event.dart';
import 'package:first_project/views/event-logic/event_detail.dart';
import 'package:first_project/views/group-functions/calendar-group/group_details.dart';
import 'package:first_project/views/group-functions/calendar-group/group_settings.dart';
import 'package:first_project/views/group-functions/create_group_data.dart';
import 'package:first_project/views/group-functions/edit_group.dart';
import 'package:first_project/views/group-functions/edit_group_data.dart';
import 'package:first_project/views/group-functions/show-groups/show_groups.dart';
import 'package:first_project/views/log-user/login_view.dart';
import 'package:first_project/views/log-user/register_view.dart';
import 'package:first_project/views/log-user/verify_email_view.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:first_project/views/provider/provider_management.dart';
import 'package:first_project/views/provider/theme_preference_provider.dart';
import 'package:first_project/views/settings.dart';
import 'package:first_project/views/show_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  final User? currentUser;

  const MyApp({Key? key, this.currentUser}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Group> fetchedGroups;

  @override
  void initState() {
    super.initState();
    // Fetch user groups asynchronously in the initState
    fetchUserGroups();
  }

  Future<void> fetchUserGroups() async {
    final providerManagement =
        Provider.of<ProviderManagement>(context, listen: false);
    final StoreService storeService =
        Provider.of<StoreService>(context, listen: false);

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
    final providerManagement = Provider.of<ProviderManagement>(context);
    final User? currentUser = providerManagement.user;
    // final bool isLoggedIn = currentUser != null;

    return Consumer<ThemePreferenceProvider>(
        builder: (context, themeProvider, child) {
      return MaterialApp(
          theme: themeProvider.themeData,
          // ... other MaterialApp properties
          routes: {
            settings: (context) => const Settings(),
            // loginRoute: (context) => const LoginView(onLoginSuccess: (User ) {  },),
            loginRoute: (context) => LoginView(onLoginSuccess: (user) {
              AppInitializer.goToMain(context, user);
            }),
            registerRoute: (context) => const RegisterView(),
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
                return EditGroup(group: group);
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
          home: const ShowGroups());
    });
  }
}
