import 'dart:developer' as devtools show log;

import 'package:calendar_app_frontend/a-models/group_model/event/event_group_resolver.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_service.dart';
import 'package:calendar_app_frontend/b-backend/api/event/event_services.dart';
import 'package:calendar_app_frontend/c-frontend/a-home-section/home_page.dart';
import 'package:calendar_app_frontend/c-frontend/d-log-user-section/register/register_view.dart';
import 'package:calendar_app_frontend/c-frontend/routes/routes.dart';
import 'package:calendar_app_frontend/d-stateManagement/event/event_data_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/local/LocaleProvider.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/theme/theme_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/theme/theme_preference_provider.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/presence_manager.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:calendar_app_frontend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        // 1. Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<AuthService>(
          create: (ctx) => AuthService(ctx.read<AuthProvider>()),
        ),
        Provider(create: (_) => GroupEventResolver()),

        // 2. User + group
        ChangeNotifierProvider(
          create: (_) => UserManagement(
            user: null,
            notificationManagement: NotificationManagement(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => GroupManagement(user: null)),

        // 3. Notifications, theming, locale
        ChangeNotifierProvider(create: (_) => NotificationManagement()),
        ChangeNotifierProvider(create: (_) => ThemeManagement()),
        ChangeNotifierProvider(create: (_) => ThemePreferenceProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => PresenceManager()),

        // 4. API services
        Provider(create: (_) => EventService()),

        // 5. Safe EventDataManager
        ProxyProvider3<GroupManagement, EventService, GroupEventResolver,
            EventDataManager>(
          create: (_) {
            final groupMgmt = _.read<GroupManagement>();
            final currentGroup = groupMgmt.currentGroup;

            if (currentGroup == null) {
              throw UnimplementedError(
                'EventDataManager should not be created until currentGroup is available.',
              );
            }

            final edm = EventDataManager(
              [],
              group: currentGroup,
              eventService: _.read<EventService>(),
              groupManagement: groupMgmt,
              resolver: _.read<GroupEventResolver>(),
            );

            edm.onExternalEventUpdate = () {
              debugPrint("⚠️ Default fallback: no calendar UI registered.");
            };

            return edm;
          },
          update: (ctx, groupMgmt, eventSvc, resolver, previous) {
            final current = groupMgmt.currentGroup;
            if (current == null) return previous!;

            final edm = EventDataManager(
              previous?.baseEvents ?? [],
              group: current,
              eventService: eventSvc,
              groupManagement: groupMgmt,
              resolver: resolver,
            );

            edm.onExternalEventUpdate = previous?.onExternalEventUpdate ??
                () => debugPrint(
                    "⚠️ Default fallback: no calendar UI registered.");

            return edm;
          },
        ),
      ],
      child: const MyMaterialApp(),
    ),
  );
}

class MyMaterialApp extends StatelessWidget {
  const MyMaterialApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemePreferenceProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, _) {
        return MaterialApp(
          locale: localeProvider.locale,
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

  Future<void> _initializeUser() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final fetchedUser = await authService.getCurrentUserModel();

      devtools.log('Fetched user: $fetchedUser');

      setState(() {
        user = fetchedUser;
        isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserManagement>(context, listen: false)
            .setCurrentUser(user);
        Provider.of<GroupManagement>(context, listen: false)
            .setCurrentUser(user);
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
      return Scaffold(body: Center(child: Text(errorMessage!)));
    } else if (Provider.of<UserManagement>(context, listen: false).user !=
        null) {
      return const HomePage();
    } else {
      return const RegisterView();
    }
  }
}
