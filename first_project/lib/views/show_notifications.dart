import 'package:first_project/models/group.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification_user.dart';
import '../models/user.dart';
import '../services/auth/logic_backend/auth_service.dart';
import '../services/firestore_database/logic_backend/firestore_service.dart';

class ShowNotifications extends StatefulWidget {
  const ShowNotifications({super.key});

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  AuthService authService = new AuthService.firebase();
  late FirestoreService _storeService;
  User? currentUser;

  //** LOGIC FOR THE VIEW */

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the inherited widget in the didChangeDependencies method.
    final providerManagement = Provider.of<ProviderManagement>(context);

    // Initialize the _storeService using the providerManagement.
    _storeService = FirestoreService.firebase(providerManagement);
  }

  void getCurrentUser() {
    AuthService.firebase().generateUserCustomModel().then((User? fetchedUser) {
      if (fetchedUser != null) {
        setState(() {
          currentUser = fetchedUser;
        });
      }
    });
  }

  void addUserToGroup(NotificationUser notification) {
    //Here we add the user to the group
    _storeService.addUserToGroup(currentUser!, notification);
  }

  // Function to remove a notification at a given index
  void removeNotification(int index) async {
    if (currentUser != null &&
        index >= 0 &&
        index < currentUser!.notifications.length) {
      currentUser!.notifications.removeAt(index);
      await _storeService.updateUser(currentUser!);
      setState(() {});
    }
  }

  void sendNotificationToOwner(NotificationUser notification) async {
    //We create a notification for the owner to inform him that a guest has accepted the petition to join the group.

    NotificationUser ntOwner = NotificationUser(
        id: notification.id,
        ownerId: notification.ownerId,
        title: "New User Added to ${notification.title.toUpperCase()} Group",
        message:
            '${currentUser!.name} has accepted your invitation to join the group',
        timestamp: DateTime.now());

    User? user = null;
    //Now we look up for the owner who created the group and assign him this notification.
    user = await _storeService.getUserById(notification.ownerId);

    //We add the notification to the user
    user!.notifications.add(ntOwner);

    //We update the hasNotification field
    user.hasNewNotifications = true;

    //Now we proceed to update the user
    _storeService.updateUser(user);
  }

  void handleConfirmation(int index) async {
    if (currentUser != null &&
        index >= 0 &&
        index < currentUser!.notifications.length) {
      NotificationUser notification = currentUser!.notifications[index];
      if (notification.question.isNotEmpty) {
        Group? group = await _storeService.getGroupFromId(notification.id);
        Map<String, UserInviteStatus>? invitedUsers = group?.invitedUsers;
        if (invitedUsers != null) {
          for (final entry in invitedUsers.entries) {
            String userName = entry.key;
            UserInviteStatus inviteStatus = entry.value;
            // Access the role
            String role = inviteStatus.role;
            // Update accepted to true
            inviteStatus.accepted = true;
            // Now you can use userName, role, and inviteStatus as needed
            if (userName != currentUser!.userName) {
              //We update the group first 
              currentUser!.notifications[index].isAnswered = true;
              await _storeService.updateUser(currentUser!);
              //TODO I NEED TO ADD A NEW PARAMETER TO SPECIFY THE ROLE INTO THE GROUP'S USERS LIST
              addUserToGroup(notification);
            }
          }
        }
      }
    }
  }

  void handleNegation(int index) async {
    if (currentUser != null &&
        index >= 0 &&
        index < currentUser!.notifications.length) {
      NotificationUser notification = currentUser!.notifications[index];
      if (notification.question.isNotEmpty) {
        currentUser!.notifications[index].isAnswered = false;
        await _storeService.updateUser(currentUser!);
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
                return Dismissible(
                  key: Key(notification.id
                      .toString()), // Unique key for each notification
                  background: Container(
                    color:
                        Colors.red, // Background color when swiping to delete
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors
                        .red, // Background color when swiping in the opposite direction
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Confirm Removal"),
                          content: Text(
                              "Are you sure you want to remove this notification?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(
                                    true); // Dismiss the dialog and confirm removal
                              },
                              child: Text("Yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(
                                    false); // Dismiss the dialog and cancel removal
                              },
                              child: Text("No"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    // Remove the notification only if confirmed
                    if (direction == DismissDirection.endToStart) {
                      removeNotification(index);
                    }
                  },
                  child: Card(
                    elevation: 2.0, // Adjust elevation as needed
                    margin: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0), // Adjust margins as needed
                    child: ListTile(
                      title: Text(notification.title ?? ''),
                      subtitle: Text(notification.message ?? ''),
                      trailing: Visibility(
                        visible: notification.hasQuestion ==
                            true, // Show buttons if hasQuestion is true
                        child: Row(
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
                        ),
                      ),
                    ),
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
