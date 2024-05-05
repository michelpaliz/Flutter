import 'dart:async';

import 'package:first_project/models/group.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as devtools show log;
import '../models/notification_user.dart';
import '../models/user.dart';
import '../services/auth/logic_backend/auth_service.dart';
import '../services/firestore_database/logic_backend/firestore_service.dart';

class ShowNotifications extends StatefulWidget {
  const ShowNotifications({Key? key}) : super(key: key);

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  late AuthService _authService;
  late FirestoreService _storeService;
  User? _currentUser;
  ProviderManagement? _providerManagement;
  List<NotificationUser> _notifications = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access ProviderManagement from the context
    _providerManagement = Provider.of<ProviderManagement>(context);

    // Initialize services
    _storeService = FirestoreService.firebase(_providerManagement);
    _authService = AuthService.firebase();
    _currentUser = _providerManagement!.currentUser;
    _notifications = _currentUser!.notifications;

    // Log the size of the notification list
    // devtools.log('List size: ${_notifications.length}');
  }

  // Function to remove a notification at a given index
// Function to remove a notification at a given index
  void _removeNotification(int index) async {
    if (_currentUser != null &&
        index >= 0 &&
        index < _currentUser!.notifications.length) {
      NotificationUser notification = _currentUser!.notifications[index];
      _currentUser!.notifications.removeAt(index);
      // Remove notification from ProviderManagement
      _providerManagement!.removeNotification(notification);
      await _storeService.updateUser(_currentUser!);

      // Use a Completer to handle the asynchronous operation
      Completer<void> completer = Completer<void>();
      completer.future.then((_) {
        // Check if the widget is still mounted before calling setState
        if (mounted) {
          setState(() {
            // Update UI if needed
          });
        }
      });

      // Complete the operation
      completer.complete();
    }
  }

// Function to handle confirming a notification
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
            String role = inviteStatus.role;
            inviteStatus.accepted = true;
            if (userName == _currentUser!.userName) {
              _currentUser!.notifications[index].isAnswered = true;
              Map<String, String> userRole = {_currentUser!.userName: role};
              group?.userRoles.addEntries(userRole.entries);
              _storeService.updateGroup(group!);
              if (mounted) {
                setState(() {
                  // Update UI if needed
                });
              }
              // Send notification to admin
              _sendNotificationToAdmin(notification, true);
              // Remove the notification
              _providerManagement!.removeNotification(notification);
              // Show a SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification accepted.'),
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
          group!.invitedUsers!.remove(_currentUser!.name);
          _providerManagement!.removeNotification(notification);
        }
        _currentUser!.notifications[index].isAnswered = true;
        await _storeService.updateUser(_currentUser!);
        _sendNotificationToAdmin(notification, false);
        if (mounted) {
          setState(() {
            // Update UI if needed
          });
        }
        // Show a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notification denied.'),
          ),
        );
      }
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

  // Function to remove all notifications
  void _removeAllNotifications() async {
    if (_currentUser != null) {
      // Clear notifications using ProviderManagement
      _providerManagement?.clearNotifications();
      // Clear notifications locally
      _currentUser!.notifications.clear();
      // Update user data in Firestore
      await _storeService.updateUser(_currentUser!);
      if (mounted) {
        setState(() {
          // Update UI if needed
        });
      }
    }
  }

  // Function to parse timestamp
  DateTime parseTimestamp(String timestampString) {
    return DateTime.parse(timestampString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: _removeAllNotifications,
            tooltip: 'Remove all notifications',
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Text('No notifications available.'),
            )
          : ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 8.0),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                bool hasConfirmed = notification.isAnswered &&
                    notification.question.isNotEmpty &&
                    notification.isAnswered;

                // Skip rendering notifications that have been answered
                if (hasConfirmed) {
                  return Container(); // Return an empty container for answered notifications
                }
                return Dismissible(
                  key: Key(notification.id.toString()),
                  background: Container(
                    color: Colors.red,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
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
                                Navigator.of(context).pop(true);
                              },
                              child: Text("Yes"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: Text("No"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      // Remove the notification only if confirmed
                      _removeNotification(index);
                    }
                  },
                  child: Card(
                    elevation: 2.0, // Adjust elevation as needed
                    margin: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0), // Adjust margins as needed
                    child: ListTile(
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      trailing: Visibility(
                        visible: notification.hasQuestion == true,
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
