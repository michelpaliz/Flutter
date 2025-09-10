import 'package:calendar_app_frontend/c-frontend/f-notification-section/show-notifications/notify_phone/local_notification_helper.dart';

Future<void> initializeAppServices() async {
  await setupLocalNotifications();
  await requestIOSNotificationPermissionsManually(); // ✅ ADD THIS
}
