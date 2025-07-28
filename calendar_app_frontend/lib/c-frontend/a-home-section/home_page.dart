import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_service.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/show-groups/show_groups.dart';
import 'package:calendar_app_frontend/c-frontend/e-notification-section/show-notifications/notify_phone/local_notification_helper.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Required for Provider access

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(drawer: MyDrawer(), body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    final authService = Provider.of<AuthService>(
      context,
      listen: false,
    ); // ✅ Injected

    return FutureBuilder<void>(
      future: _initializeUser(authService),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildUserDependentView(authService);
        } else {
          return _buildLoadingIndicator();
        }
      },
    );
  }

  Future<void> _initializeUser(AuthService authService) async {
    await authService.initialize();
  }

  Widget _buildUserDependentView(AuthService authService) {
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('No user is currently logged in'));
    }

    return Column(
      children: [
        const Expanded(child: ShowGroups()),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.notifications_active),
            label: const Text('Send Test Notification'),
            onPressed: () async {
              final testTime = DateTime.now().add(const Duration(seconds: 5));
              await requestIOSNotificationPermissionsManually(); // 👈 optional if not shown before
              await scheduleLocalNotification(
                id: 999,
                title: '🔔 Test Notification',
                body:
                    'This is a test notification scheduled for 5 seconds later.',
                dateTime: testTime,
              );
              debugPrint('📆 Notification scheduled at: $testTime');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }
}
