import 'dart:developer' as devtools show log;

import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/c-frontend/a-home-section/home_page.dart';
import 'package:first_project/c-frontend/d-log-user-section/register_view.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/theme_management.dart';
import 'package:first_project/d-stateManagement/theme_preference_provider.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/l10n/l10n.dart';
import 'package:first_project/c-frontend/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'a-models/user_model/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyMaterialApp());
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<UserManagement>(
          create: (_) => UserManagement(
            user: null, // 👈 Set initially to null
            notificationManagement: NotificationManagement(),
          ),
        ),
        ChangeNotifierProvider<GroupManagement>(
          create: (_) => GroupManagement(
            user: null, // 👈 Set initially to null
          ),
        ),
        ChangeNotifierProvider<NotificationManagement>(
          create: (_) => NotificationManagement(),
        ),
        ChangeNotifierProvider<ThemeManagement>(
          create: (_) => ThemeManagement(),
        ),
        ChangeNotifierProvider<ThemePreferenceProvider>(
          create: (_) => ThemePreferenceProvider(),
        ),
      ],
      child: Consumer<ThemePreferenceProvider>(
        builder: (context, themeProvider, _) {
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
            home: const UserInitializer(),
          );
        },
      ),
    );
  }
}

class UserInitializer extends StatefulWidget {
  const UserInitializer({Key? key}) : super(key: key);

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

/// Initializes the user by fetching the current user model from the
/// AuthProvider and updating the UserManagement and GroupManagement
/// with the fetched user. It logs the fetched user and updates the state
/// to reflect loading completion. In case of an error, it logs the error
/// and updates the state with an error message.

  Future<void> _initializeUser() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fetchedUser = await authProvider.getCurrentUserModel();

      devtools.log('Fetched user: $fetchedUser');

      setState(() {
        user = fetchedUser;
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userManagement =
            Provider.of<UserManagement>(context, listen: false);
        userManagement.setCurrentUser(user);

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
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    } else if (Provider.of<UserManagement>(context, listen: false).user !=
        null) {
      return const HomePage();
    } else {
      return const RegisterView();
    }
  }
}
