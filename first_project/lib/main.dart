import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/enums/routes/appRoutes.dart';
import 'package:first_project/l10n/l10n.dart';
import 'package:first_project/models/event.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/stateManangement/theme_preference_provider.dart';
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
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
// Logic for my view
import 'package:provider/provider.dart';

import 'models/group.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  final authService = AuthService.firebase();

  runApp(MyMaterialApp(authService: authService));
}

class MyMaterialApp extends StatelessWidget {
  final AuthService authService;

  const MyMaterialApp({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProviderManagement>(
          create: (context) => ProviderManagement(user: null),
        ),
        ChangeNotifierProvider<ThemePreferenceProvider>(
          create: (context) => ThemePreferenceProvider(),
        ),
        // Add other providers as needed
      ],
      child: Consumer<ThemePreferenceProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            theme: themeProvider.themeData,
            localizationsDelegates: const [
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
                return SizedBox
                    .shrink(); // Return an empty widget or handle the error
              },
              AppRoutes.editGroup: (context) {
                final group =
                    ModalRoute.of(context)?.settings.arguments as Group?;
                if (group != null) {
                  return EditGroupData(group: group);
                }
                return SizedBox
                    .shrink(); // Return an empty widget or handle the error
              },
              AppRoutes.groupCalendar: (context) {
                final group =
                    ModalRoute.of(context)?.settings.arguments as Group?;
                if (group != null) {
                  return GroupDetails(group: group);
                }
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
            home: UserInitializer(authService: authService),
          );
        },
      ),
    );
  }
}

class UserInitializer extends StatefulWidget {
  final AuthService authService;

  const UserInitializer({Key? key, required this.authService})
      : super(key: key);

  @override
  _UserInitializerState createState() => _UserInitializerState();
}

class _UserInitializerState extends State<UserInitializer> {
  User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = await widget.authService.generateUserCustomModel();
    setState(() {
      this.user = user;
      isLoading = false;
    });

    // Move the provider state update outside the build method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerManagement =
          Provider.of<ProviderManagement>(context, listen: false);
      providerManagement.setCurrentUser(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (user != null) {
      return HomePage(); // Ensure HomePage uses the correct providers
    } else {
      return RegisterView(); // Ensure RegisterView uses the correct providers
    }
  }
}
