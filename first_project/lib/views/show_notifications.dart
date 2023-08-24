import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth/implements/auth_service.dart';
import '../services/user/user_provider.dart';

class ShowNotifications extends StatefulWidget {
  const ShowNotifications({super.key});

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  AuthService authService = new AuthService
      .firebase(); // Replace with your AuthService implementation
  User? currentUser;

  void getCurrentUser() {
    AuthService.firebase()
        .getCurrentUserAsCustomeModel()
        .then((User? fetchedUser) {
      if (fetchedUser != null) {
        setState(() {
          currentUser = fetchedUser;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    currentUser?.notifications.sort((a, b) {
      if (a.timestamp == null && b.timestamp == null) {
        return 0; // Both are null, consider them equal
      } else if (a.timestamp == null) {
        return 1; // "a" is null, so "b" should come before
      } else if (b.timestamp == null) {
        return -1; // "b" is null, so "a" should come before
      }

      DateTime aTime = DateTime.parse(a.timestamp!);
      DateTime bTime = DateTime.parse(b.timestamp!);

      return bTime.compareTo(aTime);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: currentUser?.notifications.isEmpty ?? true
          ? Center(
              child: Text('No notifications available.'),
            )
          : ListView.builder(
              itemCount: currentUser?.notifications.length,
              itemBuilder: (context, index) {
                final notification = currentUser!.notifications[index];
                return ListTile(
                  title: Text(notification.title ?? ''),
                  subtitle: Text(notification.message ?? ''),
                  trailing: Text(
                    '${notification.timestamp!.day}/${notification.timestamp!.month}/${notification.timestamp!.year} '
                    '${notification.timestamp!.hour}:${notification.timestamp!.minute}',
                  ),
                );
              },
            ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ShowNotifications(),
  ));
}
