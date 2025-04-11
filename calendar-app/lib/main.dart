import 'dart:developer' as devtools show log;

import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/l10n/l10n.dart';
import 'package:first_project/enums/routes.dart';
import 'package:first_project/b-backend/database_conection/auth_database/logic_backend/auth_provider.dart';
import 'package:first_project/b-backend/database_conection/auth_database/logic_backend/auth_service.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/theme_management.dart';
import 'package:first_project/d-stateManagement/theme_preference_provider.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/c-frontend/a-home-section/home_page.dart';
import 'package:first_project/c-frontend/d-log-user-section/register_view.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'a-models/model/user_data/user.dart';

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
        ChangeNotifierProvider<UserManagement>(
          create: (context) => UserManagement(
            notificationManagement: NotificationManagement(),
            user: authService.costumeUser,
          ),
        ),
        ChangeNotifierProvider<GroupManagement>(
          create: (context) => GroupManagement(
            user: authService.costumeUser,
          ),
        ),
        ChangeNotifierProvider<NotificationManagement>(
          create: (context) => NotificationManagement(),
        ),
        ChangeNotifierProvider<ThemeManagement>(
          create: (context) => ThemeManagement(),
        ),
        ChangeNotifierProvider<ThemePreferenceProvider>(
          create: (context) => ThemePreferenceProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
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
            routes: routes,
            home: UserInitializer(
                authService: authService), // Use UserInitializer here
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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final fetchedUser = await widget.authService.generateUserCustomModel();
      devtools.log('Fetched user ${fetchedUser}');
      setState(() {
        user = fetchedUser;
        isLoading = false;
      });

      devtools.log('Fetched userr ${user}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userManagement =
            Provider.of<UserManagement>(context, listen: false);
        userManagement.setCurrentUser(user);

        devtools.log('Fetched user ${userManagement.user}');

        final groupManagement =
            Provider.of<GroupManagement>(context, listen: false);
        groupManagement.setCurrentUser(user);
      });
    } catch (e) {
      devtools.log('Failed to initialize user: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load user data. Please try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    } else if (Provider.of<UserManagement>(context, listen: false).user !=
        null) {
      return HomePage(); // User is available
    } else {
      return RegisterView(); // User is not available
    }
  }
}
