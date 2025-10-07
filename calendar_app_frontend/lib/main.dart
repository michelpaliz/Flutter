// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hexora/a-models/group_model/event/event_group_resolver.dart';
import 'package:hexora/b-backend/core/event/api/event_api_client.dart';
import 'package:hexora/b-backend/core/event/domain/event_domain.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/core/recurrenceRule/recurrence_rule_api_client.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/auth_provider.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/auth_service.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/helper/auht_gate.dart';
import 'package:hexora/b-backend/login_user/user/domain/presence_manager.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/notification/domain/notification_domain.dart';
import 'package:hexora/c-frontend/f-notification-section/show-notifications/notify_phone/local_notification_helper.dart';
import 'package:hexora/c-frontend/routes/routes.dart';
import 'package:hexora/d-local-stateManagement/local/LocaleProvider.dart';
import 'package:hexora/d-local-stateManagement/theme/theme_management.dart';
import 'package:hexora/d-local-stateManagement/theme/theme_preference_provider.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:hexora/l10n/l10n.dart';
import 'package:hexora/utils/init_main.dart';
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
        Provider<RecurrenceRuleApiClient>(
          create: (_) => RecurrenceRuleApiClient(),
        ),
        Provider<EventApiClient>(
          create: (ctx) => EventApiClient(
            ruleService: ctx.read<RecurrenceRuleApiClient>(),
          ),
        ),
        Provider<GroupEventResolver>(
          create: (ctx) => GroupEventResolver(
            eventService: ctx.read<EventApiClient>(),
            ruleService: ctx.read<RecurrenceRuleApiClient>(),
          ),
        ),

        // 4) App state
        ChangeNotifierProvider(
          create: (_) => UserDomain(
            user: null,
            notificationDomain: NotificationDomain(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GroupDomain(
            groupEventResolver: ctx.read<GroupEventResolver>(),
            user: null,
          ),
        ),
        ChangeNotifierProvider(create: (_) => NotificationDomain()),
        ChangeNotifierProvider(create: (_) => ThemeManagement()),
        ChangeNotifierProvider(create: (_) => ThemePreferenceProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => PresenceManager()),

        // 5) EventDataManager (ensure currentGroup exists before creating)
        ProxyProvider3<GroupDomain, EventApiClient, GroupEventResolver,
            EventDomain>(
          create: (ctx) {
            final groupMgmt = ctx.read<GroupDomain>();
            final currentGroup = groupMgmt.currentGroup;
            if (currentGroup == null) {
              throw UnimplementedError(
                'EventDataManager should not be created until currentGroup is available.',
              );
            }
            final edm = EventDomain(
              [],
              context: ctx,
              group: currentGroup,
              eventService: ctx.read<EventApiClient>(),
              groupDomain: groupMgmt,
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
            final edm = EventDomain(
              previous?.baseEvents ?? [],
              context: ctx,
              group: current,
              eventService: eventSvc,
              groupDomain: groupMgmt,
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
