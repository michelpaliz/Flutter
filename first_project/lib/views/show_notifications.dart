import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/models/group.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_provider.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
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
  late Stream<List<NotificationUser>> _notificationsStream;
  User? _currentUser;
  late UserManagement? _userManagement;
  late NotificationManagement _notificationManagement;
  late GroupManagement _groupManagement;
  late List<NotificationUser> _notifications;
  final UserService _userService = UserService();
  final AuthProvider _authProvider = AuthProvider();

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve provider management instances
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
    _notificationManagement =
        Provider.of<NotificationManagement>(context, listen: false);
    

    // Check and set the current user
    final newUser = _userManagement?.currentUser;

    _notificationsStream = _notificationManagement.notificationStream;

    // Check if the current user has changed
    if (_currentUser != newUser) {
      setState(() {
        _currentUser = newUser;
      });
      devtools.log("Current User has changed: $_currentUser");

      // Fetch and update notifications for the new user
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchAndUpdateNotifications();
      });
    }
  }

  void _initializeStream() {
    _notificationsStream = Stream.empty();
  }

  Future<void> _fetchUserNotifications(String userName) async {
    try {
      final fetchedNotifications =
          await _userService.getNotificationsByUser(userName);
      _updateNotifications(fetchedNotifications);
    } catch (error) {
      devtools.log('Error fetching notifications: $error');
    }
  }

  Future<void> _fetchAndUpdateNotifications() async {
    if (_currentUser == null || _userManagement == null) {
      return;
    }

    try {
      devtools.log("Fetching notifications for: $_currentUser");

      if (_currentUser!.notifications.isNotEmpty) {
        await _fetchUserNotifications(_currentUser!.userName);
      } else {
        _updateNotifications([]);
      }
    } catch (error, stackTrace) {
      devtools.log('Error fetching and updating notifications: $error');
      devtools.log('StackTrace: $stackTrace');
    }
  }

  void _updateNotifications(List<NotificationUser> notifications) {
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _notificationManagement.updateNotificationStream(_notifications);
      });
    }
  }

  Future<void> _handleConfirmation(String notificationId) async {
    if (_currentUser != null) {
      final notification = _currentUser!.notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => null,
      );

      if (notification != null && notification.question.isNotEmpty) {
        final group = await _groupManagement.groupService
            .getGroupById(notification.groupId);
        final invitedUsers = group.invitedUsers;

        if (invitedUsers == null) {
          _showSnackBar('Invited users not found.');
          return;
        }

        await _processInvitationConfirmation(notification, invitedUsers, group);
      }
    }
  }

  Future<void> _processInvitationConfirmation(
    NotificationUser notification,
    Map<String, UserInviteStatus> invitedUsers,
    Group group,
  ) async {
    final userName = _currentUser!.userName;
    final inviteStatus = invitedUsers[userName];

    if (inviteStatus == null) return;

    inviteStatus.invitationAnswer = true;
    invitedUsers[userName] = inviteStatus;

    final user = await _userService.getUserByUsername(userName);
    group.userIds.add(user.id);
    group.userRoles[userName] = inviteStatus.role;

    _currentUser!.groupIds.add(group.id);
    _userManagement?.updateCurrentUser(_currentUser!);

    final updatedGroups =
        await _groupManagement.groupService.getGroupsByUser(userName);
    _groupManagement.updateGroupStream(updatedGroups);

    await _sendNotificationToAdmin(notification, true);
    await _removeNotification(notification.id);

    _showSnackBar('Notification accepted.');
  }

  Future<void> _handleNegation(String notificationId) async {
    if (_currentUser != null) {
      final notification = _currentUser!.notifications.firstWhere(
        (n) => n.id == notificationId,
        orElse: () => null,
      );

      if (notification != null &&
          notification.groupId != null &&
          notification.questionsAndAnswers.isNotEmpty) {
        final group = await _groupManagement.groupService
            .getGroupById(notification.groupId!);
        final invitedUsers = group.invitedUsers;

        if (invitedUsers != null) {
          await _processInvitationNegation(notification, invitedUsers, group);
        }
      }
    }
  }

  Future<void> _processInvitationNegation(
    NotificationUser notification,
    Map<String, UserInviteStatus> invitedUsers,
    Group group,
  ) async {
    final currentUserName = _currentUser!.userName;
    final inviteStatus = invitedUsers[currentUserName];

    if (inviteStatus != null) {
      inviteStatus.invitationAnswer = false;
      invitedUsers[currentUserName] = inviteStatus;
      invitedUsers.remove(currentUserName);
      group.invitedUsers = invitedUsers;

      await _groupManagement.groupService.updateGroup(group.id, group);
      await _removeNotification(notification.id);

      notification.isRead = true;
      await _userManagement!.updateUser(_currentUser!);

      await _sendNotificationToAdmin(notification, false);

      _showSnackBar('Notification denied.');
    }
  }

  Future<void> _removeNotification(String notificationId) async {
    if (_currentUser != null) {
      final notificationIndex =
          _currentUser!.notifications.indexWhere((n) => n.id == notificationId);

      if (notificationIndex != -1) {
        _currentUser!.notifications.removeAt(notificationIndex);
        await _notificationManagement.removeNotificationByIndex(
            notificationIndex, _userManagement!);

        if (mounted) {
          setState(() {});
        }
      } else {
        devtools.log('Notification with id $notificationId not found.');
      }
    }
  }

  Future<void> _sendNotificationToAdmin(
      NotificationUser notification, bool answer) async {
    final ntOwner = NotificationUser(
      id: notification.id,
      ownerId: notification.ownerId,
      title: "Invitation Status ${notification.title.toUpperCase()} Group",
      message:
          '${_currentUser!.userName} has ${answer ? 'accepted' : 'denied'} your invitation to join the group',
      timestamp: DateTime.now(),
    );

    final admin =
        await _userManagement!.userService.getUserById(notification.ownerId);
    admin.notifications.add(ntOwner);
    admin.hasNewNotifications = true;
    await _userManagement!.userService.updateUser(admin);
  }

  Future<void> _removeAllNotifications() async {
    if (_currentUser != null) {
      _notificationManagement.clearNotifications();
      _currentUser!.notifications.clear();
      await _userManagement!.userService.updateUser(_currentUser!);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

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
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications available.'));
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final hasConfirmed = notification.isRead &&
                  notification.questionsAndAnswers.isNotEmpty;

              if (hasConfirmed) {
                return Container();
              }

              return Dismissible(
                key: Key(notification.id.toString()),
                background: Container(
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  child: Icon(Icons.delete, color: Colors.white),
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
                    _removeNotification(notifications[index].id);
                  }
                },
                child: Card(
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: Visibility(
                      visible: notification.questionsAndAnswers.isNotEmpty,
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
                              await _handleNegation(notification.id);
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
