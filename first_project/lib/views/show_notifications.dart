import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/group.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_provider.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification_user.dart';
import '../models/user.dart';

class ShowNotifications extends StatefulWidget {
  const ShowNotifications({Key? key}) : super(key: key);

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  User? _currentUser;
  ProviderManagement? _providerManagement;
  late List<NotificationUser> _notifications;
  UserService _userService = UserService();
  AuthProvider user = AuthProvider();

  @override
  void initState() {
    super.initState();
    _notifications = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve provider management instance
    _providerManagement =
        Provider.of<ProviderManagement>(context, listen: false);

    // Check and set the current user
    final newUser = _providerManagement?.currentUser;
    // Check if the current user has changed
    if (_currentUser != newUser) {
      _currentUser = newUser;
      devtools.log("Current User has changed: $_currentUser");

      // Fetch and update groups for the new user
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchAndUpdateNotifications();
      });
    }
  }

  Future<void> _fetchUserNotifications(String userName) async {
    try {
      _notifications = await _userService.getNotificationsByUser(userName);
      _updateNotifications(_notifications);
    } catch (error) {
      // Handle error
      print('Error fetching notifications: $error');
    }
  }

  Future<void> _fetchAndUpdateNotifications() async {
    if (_currentUser == null || _providerManagement == null) {
      // Handle cases where currentUser or providerManagement is null
      return;
    }

    try {
      devtools.log("Current User here !!: $_currentUser");

      if (_currentUser!.notifications.isNotEmpty) {
        await _fetchUserNotifications(_currentUser!.userName);
        _updateNotifications(_providerManagement!.notifications);
      } else {
        _updateNotifications([]);
      }
    } catch (error, stackTrace) {
      // Log the error with the stack trace for better debugging
      devtools.log('Error fetching and updating notifications: $error');
      devtools.log('StackTrace: $stackTrace');
    }
  }

  void _updateNotifications(List<NotificationUser> notifications) {
    // notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _notifications = notifications;
      _providerManagement?.updateNotificationStream(_notifications);
    });
  }

  Future<void> _handleConfirmation(int index) async {
    if (_currentUser != null &&
        index >= 0 &&
        index < _currentUser!.notifications.length) {
      var notification = _providerManagement!.currentUser?.notifications[index];

      if (notification!.question.isNotEmpty) {
        Group? group = await _providerManagement?.groupService
            .getGroupById(notification.id);

        if (group == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group does not exist anymore.'),
            ),
          );
          return;
        }

        Map<String, UserInviteStatus>? invitedUsers = group.invitedUsers;

        if (invitedUsers == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invited users not found.'),
            ),
          );
          return;
        }

        for (final entry in invitedUsers.entries) {
          String userName = entry.key;
          UserInviteStatus inviteStatus = entry.value;
          String role = inviteStatus.role;
          inviteStatus.accepted = true;

          if (userName == _currentUser!.userName) {
            _currentUser!.notifications[index].isAnswered = true;
            Map<String, String> userRole = {_currentUser!.userName: role};
            group.userRoles.addEntries(userRole.entries);
            await _providerManagement?.updateGroup(group);

            if (mounted) {
              setState(() {
                // Update UI if needed
              });
            }

            _sendNotificationToAdmin(notification, true);
            await _removeNotification(index);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notification accepted.'),
              ),
            );
            return; // Exit after processing the current user's notification
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
        // Fetch the group associated with the notification
        Group group = await _providerManagement!.groupService
            .getGroupById(notification.id);
        Map<String, UserInviteStatus>? invitedUsers = group.invitedUsers;

        if (invitedUsers != null) {
          invitedUsers.remove(_currentUser!.userName);
          group.invitedUsers = invitedUsers;

          // Update the group to remove the current user from the invited list
          await _providerManagement!.groupService.updateGroup(group.id, group);

          // Remove the notification
          await _removeNotification(index);

          // Update the user with the new state
          _currentUser!.notifications[index].isAnswered = true;
          await _providerManagement!.updateUser(_currentUser!);

          // Send a notification to the admin about the negation
          _sendNotificationToAdmin(notification, false);

          // Show a SnackBar
          if (mounted) {
            setState(() {
              // Update UI if needed
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notification denied.'),
            ),
          );
        }
      }
    }
  }

  // Function to remove a notification by index
  Future<void> _removeNotification(int index) async {
    if (_currentUser != null) {
      if (index >= 0 && index < _currentUser!.notifications.length) {
        NotificationUser notification = _currentUser!.notifications[index];

        // Remove the notification from the current user's list
        _currentUser!.notifications.removeAt(index);

        // Remove the notification from ProviderManagement
        await _providerManagement!.removeNotification(notification);

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
      } else {
        devtools.log('Notification with index $index not found.');
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
        title: "Invitation Status ${notification.title.toUpperCase()} Group",
        message:
            '${_currentUser!.userName} has accepted your invitation to join the group',
        timestamp: DateTime.now(),
      );
    } else {
      ntOwner = NotificationUser(
        id: notification.id,
        ownerId: notification.ownerId,
        title: "Invitation Status ${notification.title.toUpperCase()} Group",
        message:
            '${_currentUser!.userName} has denied your invitation to join the group',
        timestamp: DateTime.now(),
      );
    }

    // Look up for the admin (owner) who created the group.
    // User? admin = await _storeService.getUserById(notification.ownerId);
    User admin = await _providerManagement!.userService
        .getUserById(notification.ownerId);

    // Add the notification to the admin's notifications list.
    admin.notifications.add(ntOwner);

    // Update the hasNotification field.
    admin.hasNewNotifications = true;

    // Update the admin's information.
    // await _storeService.updateUser(admin);
    await _providerManagement!.userService.updateUser(admin);
  }

  // Function to remove all notifications
  void _removeAllNotifications() async {
    if (_currentUser != null) {
      // Clear notifications using ProviderManagement
      _providerManagement?.clearNotifications();
      // Clear notifications locally
      _currentUser!.notifications.clear();
      // Update user data in Firestore
      // await _storeService.updateUser(_currentUser!);
      await _providerManagement!.userService.updateUser(_currentUser!);
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
                        visible: notification.question.isNotEmpty,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () async {
                                await _handleConfirmation(index);
                              },
                              child: Text("Confirm"),
                            ),
                            TextButton(
                              onPressed: () async {
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
