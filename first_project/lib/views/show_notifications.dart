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
  User? _currentUser;

  //** LOGIC FOR THE VIEW */

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the inherited widget in the didChangeDependencies method.
    final providerManagement = Provider.of<ProviderManagement>(context);

    // Initialize the _storeService using the providerManagement.
    _storeService = FirestoreService.firebase(providerManagement);
  }

  void _getCurrentUser() {
    AuthService.firebase().generateUserCustomModel().then((User? fetchedUser) {
      if (fetchedUser != null) {
        setState(() {
          _currentUser = fetchedUser;
        });
      }
    });
  }

  void _addUserToGroup(NotificationUser notification) {
    //Here we add the user to the group
    _storeService.addUserToGroup(_currentUser!, notification);
  }

  // Function to remove a notification at a given index
  void _removeNotification(int index) async {
    if (_currentUser != null &&
        index >= 0 &&
        index < _currentUser!.notifications.length) {
      _currentUser!.notifications.removeAt(index);
      await _storeService.updateUser(_currentUser!);
      setState(() {});
    }
  }

  void _sendNotificationToAdmin(
      NotificationUser notification, bool answer) async {
    // Create a notification for the admin to inform them about the user's response to the invitation.
    NotificationUser ntOwner;

    if (answer) {
      ntOwner = NotificationUser(
        id: notification.id,
        ownerId: notification.ownerId,
        title: "New User Added to ${notification.title.toUpperCase()} Group",
        message:
            '${_currentUser!.name} has accepted your invitation to join the group',
        timestamp: DateTime.now(),
      );
    } else {
      ntOwner = NotificationUser(
        id: notification.id,
        ownerId: notification.ownerId,
        title: "New User Added to ${notification.title.toUpperCase()} Group",
        message:
            '${_currentUser!.name} has denied your invitation to join the group',
        timestamp: DateTime.now(),
      );
    }

    // Look up for the admin (owner) who created the group.
    User? admin = await _storeService.getUserById(notification.ownerId);

    if (admin != null) {
      // Add the notification to the admin's notifications list.
      admin.notifications.add(ntOwner);

      // Update the hasNotification field.
      admin.hasNewNotifications = true;

      // Update the admin's information.
      await _storeService.updateUser(admin);
    }
  }

  void _handleConfirmation(int index) async {
    if (_currentUser != null &&
        index >= 0 &&
        index < _currentUser!.notifications.length) {
      NotificationUser notification = _currentUser!.notifications[index];
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
            if (userName == _currentUser!.userName) {
              //We update the group first
              _currentUser!.notifications[index].isAnswered = true;
              await _storeService.updateUser(_currentUser!);
              _addUserToGroup(notification);
              //Update the group user roles list
              Map<String, String> userRole = {
                "id": _currentUser!.userName,
                "role": role
              };
              group?.userRoles.addEntries(userRole.entries);
              _storeService.updateGroup(group!);

              //Send notification to admin
              setState(() {});
              _sendNotificationToAdmin(notification, true);
              // Show a SnackBar with a denial message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification accepted .'),
                ),
              );
            }
          }
        }
      }
    }
  }

  void _handleNegation(int index) async {
    if (_currentUser != null &&
        index >= 0 &&
        index < _currentUser!.notifications.length) {
      NotificationUser notification = _currentUser!.notifications[index];
      if (notification.question.isNotEmpty) {
        Group? group = await _storeService.getGroupFromId(notification.id);
        Map<String, UserInviteStatus>? invitedUsers = group?.invitedUsers;
        if (invitedUsers != null) {
          //we proceed to remove the invitation from the group user list
          group!.invitedUsers!.remove(_currentUser!.name);
        }
        _currentUser!.notifications[index].isAnswered = true;
        await _storeService.updateUser(_currentUser!);
        _addUserToGroup(notification);

        //SEND NOTIFICATION TO ADMIN
        setState(() {});

        _sendNotificationToAdmin(notification, false);

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
    _currentUser?.notifications.sort((a, b) {
      DateTime aTime = parseTimestamp(a.timestamp!.toString());
      DateTime bTime = parseTimestamp(b.timestamp!.toString());

      return bTime.compareTo(aTime); // Compare DateTime objects
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: _currentUser?.notifications.isEmpty ?? true
          ? Center(
              child: Text('No notifications available.'),
            )
          : ListView.builder(
            //** SHOW THE NOTIFICATIONS AVAILABLE  */
              itemCount: _currentUser?.notifications.length,
              itemBuilder: (context, index) {
                final notification = _currentUser!.notifications[index];
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
                  //** HANDLE NOTIFICATIONS WITHOUT QUESTIONS  */
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
                      _removeNotification(index);
                    }
                  },
                  //** HANDLE NOTIFICATIONS WITH QUESTIONS  */
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
                                _handleConfirmation(index);
                              },
                              child: Text("Confirm"),
                            ),
                            TextButton(
                              onPressed: () {
                                _handleNegation(index);
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
