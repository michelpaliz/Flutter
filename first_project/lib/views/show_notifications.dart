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

      // Fetch and update notifications for the new user
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
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _notifications = notifications;
      _providerManagement?.updateNotificationStream(_notifications);
    });
  }

// Asynchronous function to handle confirmation of a notification
  Future<void> _handleConfirmation(String notificationId) async {
    // Check if there is a current user
    if (_currentUser != null) {
      // Retrieve the notification with the given ID from the current user's notifications
      var notification = _providerManagement!.currentUser?.notifications
          .firstWhere((n) => n.id == notificationId);

      // If the notification exists and contains a question
      if (notification != null && notification.question.isNotEmpty) {
        // Fetch the group associated with the notification
        Group? group = await _providerManagement?.groupService
            .getGroupById(notification.groupId);

        // If the group does not exist, show a snackbar message and return
        if (group == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group does not exist anymore.'),
            ),
          );
          return;
        }

        // Retrieve the list of invited users for the group
        Map<String, UserInviteStatus>? invitedUsers = group.invitedUsers;

        // If the invited users list is not found, show a snackbar message and return
        if (invitedUsers == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invited users not found.'),
            ),
          );
          return;
        }

        // Iterate over each invited user
        for (final entry in invitedUsers.entries) {
          String userName = entry.key; // Get the user's name
          UserInviteStatus inviteStatus =
              entry.value; // Get the user's invite status
          String role = inviteStatus.role; // Get the user's role
          inviteStatus.accepted = true; // Mark the invite as accepted

          //We add the new users here
          User user = await _userService.getUserByUsername(userName);
          group.userIds.add(user.id);

          // If the current user is the one being processed
          if (userName == _currentUser!.userName) {
            notification.isAnswered = true; // Mark the notification as answered
            // Add the user's role to the group's user roles
            Map<String, String> userRole = {_currentUser!.userName: role};
            group.userRoles.addEntries(userRole.entries);

            // Add the group ID to the current user's group IDs
            _currentUser!.groupIds.add(group.id);

            // Update the group with the new user roles
            await _providerManagement?.updateGroup(group);
            // Update the current user with the new group ID
            _providerManagement?.updateCurrentUser(_currentUser!);

            List<Group> updatedGroups = await _providerManagement!.groupService
                .getGroupsByUser(_currentUser!.userName);

            _providerManagement!.updateGroupStream(updatedGroups);

            // If the widget is still mounted, update the UI
            if (mounted) {
              setState(() {
                // Update UI if needed
              });
            }

            // Send a notification to the admin indicating the notification was accepted
            _sendNotificationToAdmin(notification, true);
            // Remove the notification
            await _removeNotification(notification.id);

            // Show a snackbar message indicating the notification was accepted
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

  void _handleNegation(String notificationId) async {
    if (_currentUser != null) {
      NotificationUser? notification =
          _currentUser!.notifications.firstWhere((n) => n.id == notificationId);

      if (notification != null &&
          notification.groupId!.isNotEmpty &&
          notification.question.isNotEmpty) {
        // Fetch the group associated with the notification
        Group group = await _providerManagement!.groupService
            .getGroupById(notification.groupId!);
        Map<String, UserInviteStatus>? invitedUsers = group.invitedUsers;

        if (invitedUsers != null) {
          invitedUsers.remove(_currentUser!.userName);
          group.invitedUsers = invitedUsers;

          // Update the group to remove the current user from the invited list
          await _providerManagement!.groupService.updateGroup(group.id, group);

          // Remove the notification
          await _removeNotification(notification.id);

          // Update the user with the new state
          notification.isAnswered = true;
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

  // Function to remove a notification by id
  Future<void> _removeNotification(String notificationId) async {
    if (_currentUser != null) {
      NotificationUser? notification =
          _currentUser!.notifications.firstWhere((n) => n.id == notificationId);

      if (notification != null) {
        // Remove the notification from the current user's list
        _currentUser!.notifications.removeWhere((n) => n.id == notificationId);

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
        devtools.log('Notification with id $notificationId not found.');
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
    User admin = await _providerManagement!.userService
        .getUserById(notification.ownerId);

    // Add the notification to the admin's notifications list.
    admin.notifications.add(ntOwner);

    // Update the hasNotification field.
    admin.hasNewNotifications = true;

    // Update the admin's information.
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
                      _removeNotification(notification.id);
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
                                await _handleConfirmation(notification.id);
                              },
                              child: Text("Confirm"),
                            ),
                            TextButton(
                              onPressed: () async {
                                _handleNegation(notification.id);
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
