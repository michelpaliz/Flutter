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
  late AuthService _authService;
  late FirestoreService _storeService;
  User? _currentUser;
  ProviderManagement? _providerManagement;
  bool _isLoading =
      true; // Initially set to true to display the progress indicator

  //** LOGIC FOR THE VIEW */

  @override
  void initState() {
    super.initState();
    _providerManagement =
        Provider.of<ProviderManagement>(context, listen: false);
    _storeService = FirestoreService.firebase(_providerManagement);
    _authService = AuthService.firebase();
    _providerManagement!.notificationStream.listen((notifications) {
      setState(() {
        _currentUser!.notifications = notifications;
        _isLoading = false;
      });
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   // Access the inherited widget in the didChangeDependencies method.
  //   _providerManagement = Provider.of<ProviderManagement>(context);

  //   // Initialize the _storeService using the providerManagement.
  //   _storeService = FirestoreService.firebase(_providerManagement);
  //   _authService = new AuthService.firebase();
  //   _providerManagement!.updateNotificationStream(_currentUser!.notifications);
  // }

  // Future<void> populateNotificationList() async {
  //   try {
  //     // final fetchedNotifications =
  //     //     await _storeService.fetchUserGroups(_currentUser!.groupIds);
  //     // _providerManagement?.updateGroupStream(fetchedNotifications);

  //   } catch (error) {
  //     print('Error fetching and updating groups: $error');
  //   }
  // }

  // void _getCurrentUser() {
  //   // setState(() {
  //   //   _isLoading = true; // Start loading
  //   // });
  //   // AuthService.firebase().generateUserCustomModel().then((User? fetchedUser) {
  //   //   if (fetchedUser != null && mounted) {
  //   //     setState(() {
  //   //       _currentUser = fetchedUser;
  //   //       _isLoading = false; // Stop loading
  //   //     });
  //   //   }
  //   // });
  //   // new AuthService.firebase();
  // }

  @override
  void dispose() {
    // Perform cleanup tasks here, if needed
    super.dispose();
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
      if (mounted) {
        setState(() {
          // Update relevant UI state here if needed
        });
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

  void _handleConfirmation(int index) async {
    if (_currentUser != null &&
        index >= 0 &&
        index < _currentUser!.notifications.length) {
      NotificationUser notification = _currentUser!.notifications[index];
      if (notification.question.isNotEmpty) {
        Group? group = await _storeService.getGroupFromId(notification.id);
        Map<String, UserInviteStatus>? invitedUsers = group?.invitedUsers;
        // !Now we fill out the form with the information that we got from the invite status.
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
              //Update the group user roles list
              Map<String, String> userRole = {_currentUser!.userName: role};
              group?.userRoles.addEntries(userRole.entries);
              _addUserToGroup(notification);
              _storeService.updateGroup(
                  group!); //We need to update the group user roles list after a change made to the group

              if (mounted) {
                setState(() {
                  // Update relevant UI state here if needed
                });
              }
              //Send notification to admin
              _sendNotificationToAdmin(notification, true);
              //After answer the notification we proceed to remove the notification
              _providerManagement!.removeNotification(notification);
              // Show a SnackBar with a denial message
              if (mounted) {
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
          _providerManagement!.removeNotification(notification);
        }
        _currentUser!.notifications[index].isAnswered = true;
        await _storeService.updateUser(_currentUser!);
        _addUserToGroup(notification);

        //SEND NOTIFICATION TO ADMIN
        if (mounted) {
          setState(() {
            // Update relevant UI state here if needed
          });
        }
        _sendNotificationToAdmin(notification, false);

        // Show a SnackBar with a denial message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Notification denied .'),
            ),
          );
        }
      }
    }
  }

  void _removeAllNotifications() async {
    if (_currentUser != null) {
      // Clear notifications using ProviderManagement
      _providerManagement?.clearNotifications();

      // Clear notifications locally (optional)
      _currentUser!.notifications.clear();

      // Update user data in Firestore
      await _storeService.updateUser(_currentUser!);

      if (mounted) {
        setState(() {
          // Update relevant UI state here if needed
        });
      }
    }
  }

  //** UI FOR THE VIEW */

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
      body: StreamBuilder<List<NotificationUser>>(
        stream: _providerManagement!.notificationStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<NotificationUser>? notifications = snapshot.data;
            if (notifications == null || notifications.isEmpty) {
              return Center(
                child: Text('No notifications available.'),
              );
            } else {
              // Sort notifications
              notifications.sort((a, b) {
                DateTime aTime = parseTimestamp(a.timestamp.toString());
                DateTime bTime = parseTimestamp(b.timestamp.toString());
                return bTime.compareTo(aTime);
              });

              return ListView.builder(
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
              );
            }
          }
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
