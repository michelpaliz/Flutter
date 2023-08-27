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

  void sendNotificationToOwner(NotificationUser notification) async {
    //We create a notification for the owner to inform him that a guest has accepted the petition to join the group.
    NotificationUser ntOwner = NotificationUser(
        id: notification.id,
        ownerId: notification.ownerId,
        title: notification.title,
        message: '${currentUser!.name} has accepted your invitation to join the group',
        timestamp: DateTime.now());
    
    User? user = null;
    //Now we look up for the owner who created the group and assign him this notification.
    user = await storeService.getUserById(notification.ownerId);

    //We add the notification to the user
    user!.notifications.add(ntOwner);

    //Now we proceed to update the user
    storeService.updateUser(user);
  }

  void handleConfirmation(int index) async {
    if (currentUser != null &&
        index >= 0 &&
        index < currentUser!.notifications.length) {
      NotificationUser notification = currentUser!.notifications[index];
      if (!notification.isAnswered && notification.question.isNotEmpty) {
        currentUser!.notifications[index].isAnswered = true;
        await storeService.updateUser(currentUser!);
        addUserToGroup(notification);
        setState(() {});

        sendNotificationToOwner(notification);

        // Show a SnackBar with a confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification confirmed.'),
          ),
        );
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
        addUserToGroup(notification);
        setState(() {});

        sendNotificationToOwner(notification);

        // Show a SnackBar with a denial message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification denied.'),
          ),
        );
      }
    }
  }

  //** UI FOR THE VIEW */

  DateTime parseTimestamp(String timestampString) {
    return DateTime.parse(timestampString);
  }

  @override
  Widget build(BuildContext context) {
    // getCurrentUser();
    currentUser?.notifications.sort((a, b) {
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

                // Skip rendering notifications that have been answered
                if (hasConfirmed) {
                  return Container(); // Return an empty container for answered notifications
                }

                return ListTile(
                  title: Text(notification.title ?? ''),
                  subtitle: Text(notification.message ?? ''),
                  trailing: notification.hasQuestion
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () {
                                handleConfirmation(index);
                              },
                              child: Text("Confirm"),
                            ),
                            TextButton(
                              onPressed: () {
                                handleNegation(index);
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
