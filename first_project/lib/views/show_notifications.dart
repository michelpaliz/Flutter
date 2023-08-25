import 'package:first_project/services/firestore/implements/firestore_provider.dart';
import 'package:flutter/material.dart';

import '../models/notification_user.dart';
import '../models/user.dart';
import '../services/auth/implements/auth_service.dart';
import '../services/firestore/implements/firestore_service.dart';
import '../services/user/user_provider.dart';

class ShowNotifications extends StatefulWidget {
  const ShowNotifications({super.key});

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  AuthService authService = new AuthService.firebase();
  StoreService storeService = StoreService.firebase();
  User? currentUser;

  //** LOGIC FOR THE VIEW */

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

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

  void addUserToGroup(NotificationUser notification) {
    //Here we add the user to the group
    storeService.addUserToGroup(currentUser!, notification);
  }

  void handleConfirmation(int index) async {
    if (currentUser != null &&
        index >= 0 &&
        index < currentUser!.notifications.length) {
      NotificationUser notification = currentUser!.notifications[index];
      if (!notification.isAnswered && notification.question.isNotEmpty) {
        currentUser!.notifications[index].isAnswered = true;
        await storeService.updateUser(currentUser!);
        addUserToGroup(notification); // Fixed this line
        setState(() {});
      }
    }
  }

  void handleNegation(int index) async {
    if (currentUser != null &&
        index >= 0 &&
        index < currentUser!.notifications.length) {
      NotificationUser notification = currentUser!.notifications[index];
      if (!notification.isAnswered && notification.question.isNotEmpty) {
        currentUser!.notifications[index].isAnswered = false;
        await storeService.updateUser(currentUser!);
        addUserToGroup(notification); // Fixed this line
        setState(() {});
      }
    }
  }

  //** UI FOR THE VIEW */

  DateTime parseTimestamp(String timestampString) {
    return DateTime.parse(timestampString);
  }

  @override
  Widget build(BuildContext context) {
    getCurrentUser();
    currentUser?.notifications
      .sort((a, b) {
        DateTime aTime = parseTimestamp(a.timestamp!.toString());
        DateTime bTime = parseTimestamp(b.timestamp!.toString());

        return bTime.compareTo(aTime); // Compare DateTime objects
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
                bool hasConfirmed = notification.isAnswered &&
                    notification.question.isNotEmpty &&
                    notification.isAnswered;

                return ListTile(
                  title: Text(notification.title ?? ''),
                  subtitle: Text(notification.message ?? ''),
                  trailing: notification.hasQuestion
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: hasConfirmed
                                  ? null
                                  : () {
                                      // Handle confirmation
                                      // Set the 'isAnswered' field of the notification
                                      handleConfirmation(index);
                                    },
                              child: Text("Confirm"),
                            ),
                            TextButton(
                              onPressed: hasConfirmed
                                  ? null
                                  : () {
                                      // Handle negation
                                      // Set the 'isAnswered' field of the notification
                                      handleConfirmation(index);
                                    },
                              child: Text("Negate"),
                            ),
                          ],
                        )
                      : null, // Hide buttons if there's no question
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
