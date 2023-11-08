import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/models/event.dart';
import 'package:first_project/models/routeLogger.dart';
import 'package:first_project/enums/routes/routes.dart';
import 'package:first_project/my-lib/utilities.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/views/calendar-group/group_details.dart';
import 'package:first_project/views/calendar-group/group_settings.dart';
import 'package:first_project/views/create-group/create_group_data.dart';
import 'package:first_project/views/create-group/edit_group.dart';
import 'package:first_project/views/create-group/edit_group_data.dart';
import 'package:first_project/views/show-groups/show_groups.dart';
import 'package:first_project/views/event-logic/add_event.dart';
import 'package:first_project/views/event-logic/edit_event.dart';
import 'package:first_project/views/event-logic/event_detail.dart';
import 'package:first_project/views/log-user/login_view.dart';
import 'package:first_project/views/log-user/register_view.dart';
import 'package:first_project/views/log-user/verify_email_view.dart';
import 'package:first_project/views/notes_view.dart';
import 'package:first_project/views/provider/app_services.dart';
import 'package:first_project/views/provider/provider_management.dart';
import 'package:first_project/views/settings.dart';
import 'package:first_project/views/show_notifications.dart';
import 'package:flutter/material.dart';
//** Logic for my view */
// main.dart
import 'package:provider/provider.dart';

import 'models/group.dart';
import 'models/user.dart';
// ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load custom fonts
  await Utilities.loadCustomFonts();
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (error) {
    print('Error initializing Firebase: $error');
  }

  // Create an instance of AuthService
  final AuthService authService = AuthService.firebase();

  // Initialize AuthService (if needed, e.g., for authentication)
  try {
    await authService.initialize();
  } catch (error) {
    print('Error initializing AuthService: $error');
  }

  // Generate the custom user model
  User? customUser = await authService.generateUserCustomeModel();

// Check if customUser is null
  if (customUser == null) {
    // User is new or not logged in, direct them to the login screen
    runApp(
      MyApp(currentUser: customUser),
    );
  } else {
    // Set the custom user model in AuthService
    authService.costumeUser = customUser;

    // Create an instance of ProviderManagement
    final providerManagement = ProviderManagement(user: customUser);

    // Initialize the StoreService by providing the ProviderManagement
    StoreService storeService = StoreService.firebase(providerManagement);

    //Fetched user groups for the provider

    List<Group>? fetchedGroups =
        await storeService.fetchUserGroups(customUser.groupIds);

    //Set the user groups into the service
    providerManagement.setGroups = fetchedGroups;

    // Create an instance of AppServices to provide the StoreService
    AppServices appServices = AppServices(providerManagement, storeService);

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProviderManagement>.value(
              value: appServices.providerManagement),
          Provider<AppServices>.value(
              value: appServices), // Provide AppServices at the root level
        ],
        child: MyApp(currentUser: customUser),
      ),
    );
  }
}

//** UI for my view */
class MyApp extends StatelessWidget {
  final User? currentUser;

  const MyApp({Key? key, this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final providerManagement = Provider.of<ProviderManagement>(context);
    final User? currentUser = providerManagement.user;

    final bool isLoggedIn = currentUser != null;

    return MaterialApp(
      title: 'Flutter Demo',
      navigatorObservers: [RouteLogger()],
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        settings: (context) => const Settings(),
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        userCalendar: (context) => const NotesView(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        editEvent: (context) {
          final event = ModalRoute.of(context)?.settings.arguments as Event?;
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
          final group = ModalRoute.of(context)?.settings.arguments as Group?;
          if (group != null) {
            return GroupSettings(group: group);
          }
          // Handle the case when no group is passed
          return SizedBox
              .shrink(); // Return an empty widget or handle the error
        },
        editGroup: (context) {
          final group = ModalRoute.of(context)?.settings.arguments as Group?;
          if (group != null) {
            return EditGroup(group: group);
          }
          // Handle the case when no group is passed
          return SizedBox
              .shrink(); // Return an empty widget or handle the error
        },
        groupCalendar: (context) {
          final group = ModalRoute.of(context)?.settings.arguments as Group?;
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
          final event = ModalRoute.of(context)?.settings.arguments as Event?;
          if (event != null) {
            return EventDetail(event: event);
          }
          return SizedBox
              .shrink(); // Return an empty widget or handle the error
        },
        editGroupData: (context) {
          final group = ModalRoute.of(context)?.settings.arguments as Group?;
          if (group != null) {
            return EditGroupData(group: group);
          }
          return SizedBox
              .shrink(); // Return an empty widget or handle the error
        }
      },
      home: isLoggedIn ? const ShowGroups() : const LoginView(),
    );
  }
}
