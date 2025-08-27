// main.dart
import 'package:calendar_app_frontend/a-models/group_model/event/event_group_resolver.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_provider.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_service.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/helper/auht_gate.dart';
import 'package:calendar_app_frontend/b-backend/api/event/event_services.dart';
import 'package:calendar_app_frontend/b-backend/api/recurrenceRule/recurrence_rule_services.dart';
import 'package:calendar_app_frontend/c-frontend/e-notification-section/show-notifications/notify_phone/local_notification_helper.dart';
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
import 'package:calendar_app_frontend/utils/init_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppServices();
  await setupLocalNotifications();

  runApp(
    MultiProvider(
      providers: [
        // 1) Auth repo FIRST (concrete ChangeNotifier)
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),

        // 2) AuthService depends on the repo
        ChangeNotifierProvider<AuthService>(
          create: (ctx) => AuthService(ctx.read<AuthProvider>()),
        ),

        // 3) Shared API services (single instances for the whole app)
        Provider<RecurrenceRuleService>(
          create: (_) => RecurrenceRuleService(),
        ),
        Provider<EventService>(
          create: (ctx) => EventService(
            ruleService: ctx.read<RecurrenceRuleService>(),
          ),
        ),
        Provider<GroupEventResolver>(
          create: (ctx) => GroupEventResolver(
            eventService: ctx.read<EventService>(),
            ruleService: ctx.read<RecurrenceRuleService>(),
          ),
        ),

        // 4) App state
        ChangeNotifierProvider(
          create: (_) => UserManagement(
            user: null,
            notificationManagement: NotificationManagement(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GroupManagement(
            groupEventResolver: ctx.read<GroupEventResolver>(),
            user: null,
          ),
        ),
        ChangeNotifierProvider(create: (_) => NotificationManagement()),
        ChangeNotifierProvider(create: (_) => ThemeManagement()),
        ChangeNotifierProvider(create: (_) => ThemePreferenceProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => PresenceManager()),

        // 5) EventDataManager (ensure currentGroup exists before creating)
        ProxyProvider3<GroupManagement, EventService, GroupEventResolver,
            EventDataManager>(
          create: (ctx) {
            final groupMgmt = ctx.read<GroupManagement>();
            final currentGroup = groupMgmt.currentGroup;
            if (currentGroup == null) {
              throw UnimplementedError(
                'EventDataManager should not be created until currentGroup is available.',
              );
            }
            final edm = EventDataManager(
              [],
              context: ctx,
              group: currentGroup,
              eventService: ctx.read<EventService>(),
              groupManagement: groupMgmt,
              resolver: ctx.read<GroupEventResolver>(),
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
              context: ctx,
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
          home: const AuthGate(), // ✅ uses the UI AuthGate
        );
      },
    );
  }
}
