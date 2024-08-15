import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/enums/broad_category.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:first_project/utilities/notification_formats.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/notification_user.dart';
import '../models/user.dart';

class ShowNotifications extends StatefulWidget {
  final User user;
  const ShowNotifications({required this.user, Key? key}) : super(key: key);

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  final BroadCategoryManager _categoryManager = BroadCategoryManager();
  BroadCategory _selectedCategory =
      BroadCategory.group; // Initialize with an appropriate value

  late Stream<List<NotificationUser>> _notificationsStream;
  late User _currentUser = widget.user;
  late UserManagement _userManagement;
  late NotificationManagement _notificationManagement;
  late GroupManagement _groupManagement;
  late List<NotificationUser> _notifications;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    // Initialize _currentUser using the passed user
    _currentUser = widget.user;

    _initializeStream();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchAndUpdateNotifications();
    });
  }

  void didChangeDependencies() {
    super.didChangeDependencies();

    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
    _notificationManagement =
        Provider.of<NotificationManagement>(context, listen: false);

    // Check if _userManagement.currentUser is not null
    if (_userManagement.currentUser != null) {
      _currentUser = _userManagement.currentUser!;
      _notificationsStream = _notificationManagement.notificationStream;
      setState(() {
        _currentUser;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchAndUpdateNotifications();
      });
    } else {
      // Handle the case where currentUser is null, e.g., by showing a loading indicator
      devtools.log("Current User is null");
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
    try {
      devtools.log("Fetching notifications for: $_currentUser");

      if (_currentUser.notifications.isNotEmpty) {
        await _fetchUserNotifications(_currentUser.userName);
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

  Future<void> _handleConfirmation(NotificationUser notification) async {
    // Check if there are any questions and answers in the notification
    if (notification.questionsAndAnswers.isNotEmpty) {
      try {
        // Fetch the group details using the group ID from the notification
        final groupFetched = await _groupManagement.groupService
            .getGroupById(notification.groupId!);
        final invitedUsers = groupFetched.invitedUsers;

        // If no invited users are found, show a snackbar message
        if (invitedUsers == null) {
          _showSnackBar('Invited users not found.');
          return;
        }

        // Process the invitation confirmation
        await _processInvitationConfirmation(
            notification, invitedUsers, groupFetched);
      } catch (e) {
        // Log the error and show a snackbar message if fetching the group fails
        devtools.log('Error fetching group: $e');
        _showSnackBar('Error fetching group information.');
      }
    }
  }

  Future<void> _processInvitationConfirmation(
    NotificationUser notification,
    Map<String, UserInviteStatus> invitedUsers,
    Group group,
  ) async {
    User userInvited = await _userService.getUserById(notification.recipientId);

    //!UPDATE THE USER INVITED INVITATION

    for (NotificationUser ntf in userInvited.notifications) {
      if (ntf.groupId == group.id) {
        // Assuming there's only one key-value pair in questionsAndAnswers
        String questionKey = ntf.questionsAndAnswers.keys.first;

        // Update the value for the specific key
        ntf.questionsAndAnswers
            .update(questionKey, (value) => 'Has accepted the invitation');
      }
    }

    devtools.log("User invited ${userInvited}");

    //!UPDATE THE GROUP INVITATION DATA FOR THE INVITED USER

    // Get the invited user's username
    final inviteStatus = invitedUsers[userInvited.userName];

    // Update the invitation answer to true
    inviteStatus!.invitationAnswer = true;
    invitedUsers[userInvited.userName] = inviteStatus;

    // Fetch the user details using the username
    group.userIds.add(userInvited.id);
    group.userRoles[userInvited.userName] = inviteStatus.role;

    // Add the group ID to the invited user's group IDs and update the user
    userInvited.groupIds.add(group.id);

    // Call the second function to update the group and send notifications
    await _updateGroupAndSendNotifications(
        notification, userInvited, group, invitedUsers);
  }

  Future<void> _updateGroupAndSendNotifications(
    NotificationUser notification,
    User userInvited,
    Group group,
    Map<String, UserInviteStatus> invitedUsers,
  ) async {
    devtools.log("Update group ${group}");
    devtools.log("Update admin ${userInvited}");

    //!UPDATE THE DATA FOR THE DB
    await _userManagement.updateUser(userInvited);
    await _groupManagement.updateGroup(
        group, _userManagement, _notificationManagement, invitedUsers);

    // Create a new notification for the user being added to the group
    final notificationFormat = NotificationFormats();
    NotificationUser invitedUserHasJoined =
        notificationFormat.welcomeNewUserGroup(group, userInvited);

    // Add the notification and check if it was successful
    bool notificationAdded = await _notificationManagement.addNotificationToDB(
        invitedUserHasJoined, _userManagement);

    if (notificationAdded) {
      // Send a notification to the admin and remove the original notification if it exists
      await _sendNotificationToAdmin(notification, true);

      // Remove the original notification by its ID
      bool notificationRemoved = await _notificationManagement
          .removeNotificationById(notification, _userManagement);

      if (notificationRemoved) {
        _showSnackBar('Notification accepted.');
      } else {
        _showSnackBar('Notification not found.');
      }
    } else {
      _showSnackBar('Failed to send join notification.');
    }
  }

  Future<void> _handleNegation(NotificationUser notification) async {
    if (notification.groupId != null &&
        notification.questionsAndAnswers.isNotEmpty) {
      final group = await _groupManagement.groupService
          .getGroupById(notification.groupId!);
      final invitedUsers = group.invitedUsers;

      if (invitedUsers != null) {
        await _processInvitationNegation(notification, invitedUsers, group);
      }
    }
  }

  Future<void> _processInvitationNegation(
    NotificationUser notification,
    Map<String, UserInviteStatus> invitedUsers,
    Group group,
  ) async {
    // Retrieve the user who was invited
    User userInvited = await _userService.getUserById(notification.recipientId);
    final currentUserName = userInvited.userName;
    final inviteStatus = invitedUsers[currentUserName];

    if (inviteStatus != null) {
      // Update the invitation status and remove the user from the invited list
      inviteStatus.invitationAnswer = false;
      invitedUsers[currentUserName] = inviteStatus;
      invitedUsers.remove(currentUserName);
      group.invitedUsers = invitedUsers;

      // Update the group in the database
      await _groupManagement.groupService.updateGroup(group);

      // Create a new notification for the user denying the group invitation
      final notificationFormat = NotificationFormats();
      NotificationUser denyNotification =
          notificationFormat.notificationUserDenyGroup(group, userInvited);

      // Add the denial notification to the database
      bool notificationAdded = await _notificationManagement
          .addNotificationToDB(denyNotification, _userManagement);

      // Remove the original invitation notification
      bool notificationRemoved = await _notificationManagement
          .removeNotificationById(notification, _userManagement);

      if (notificationAdded && notificationRemoved) {
        // Send a notification to the admin and show a success message
        await _sendNotificationToAdmin(notification, false);
        _showSnackBar('Notification denied.');
      } else {
        if (!notificationAdded) {
          _showSnackBar('Failed to send notification.');
        }
        if (!notificationRemoved) {
          _showSnackBar('Notification not found.');
        }
      }
    }
  }

  Future<void> _removeNotificationByIndex(int index) async {
    bool success = await _notificationManagement.removeNotificationByIndex(
        index, _userManagement);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove notification')),
      );
    }
  }

  Future<void> _sendNotificationToAdmin(
      NotificationUser notification, bool answer) async {
    final ntOwner = NotificationUser(
      id: notification.id,
      senderId: notification.senderId,
      recipientId: notification.senderId,
      title: "Invitation Status ${notification.title.toUpperCase()} Group",
      message:
          '${_currentUser.userName} has ${answer ? 'accepted' : 'denied'} your invitation to join the group',
      timestamp: DateTime.now(),
      category: Category.groupUpdate,
    );

    final admin =
        await _userManagement.userService.getUserById(notification.senderId);
    admin.notifications.add(ntOwner);
    admin.hasNewNotifications = true;
    await _userManagement.userService.updateUser(admin);
  }

  Future<void> _removeAllNotifications() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Removal"),
          content: Text(
              "Are you sure you want to remove all notifications? This action cannot be undone."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // Proceed with removing all notifications
      _notificationManagement.clearNotifications();
      _currentUser.notifications.clear();
      await _userManagement.userService.updateUser(_currentUser);
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

  String _formatTimeDifference(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return 'Last 30 days';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  Map<String, List<NotificationUser>> _groupNotifications(
      List<NotificationUser> notifications) {
    final now = DateTime.now();
    final Map<String, List<NotificationUser>> grouped = {
      'Recent': [],
      'Last 7 days': [],
      'Last 30 days': [],
      'Older': [],
    };

    for (var notification in notifications) {
      final difference = now.difference(notification.timestamp);
      if (difference.inSeconds < 60) {
        grouped['Recent']!.add(notification);
      } else if (difference.inMinutes < 60) {
        grouped['Recent']!.add(notification);
      } else if (difference.inHours < 24) {
        grouped['Recent']!.add(notification);
      } else if (difference.inDays < 7) {
        grouped['Last 7 days']!.add(notification);
      } else if (difference.inDays < 30) {
        grouped['Last 30 days']!.add(notification);
      } else {
        grouped['Older']!.add(notification);
      }
    }

    return grouped;
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
      body: Column(
        children: [
          // Dynamic list of buttons for filtering
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: BroadCategory.values.map((category) {
                bool isSelected = _selectedCategory == category;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _categoryManager.filterNotifications(category);
                        _selectedCategory =
                            category; // Update the selected category
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: isSelected
                          ? Color.fromARGB(255, 6, 150, 138)
                          : Color.fromARGB(
                              255, 17, 158, 219), // Change colors as desired
                    ),
                    child:
                        Text(category.toString().toUpperCase().split('.').last),
                  ),
                );
              }).toList(),
            ),
          ),

          // Notification list
          Expanded(
            child: StreamBuilder<List<NotificationUser>>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No notifications available.'));
                }

                final notificationsByCategory = snapshot.data!
                    .where((notification) =>
                        _categoryManager.selectedCategory == null ||
                        _categoryManager
                                .categoryMapping[notification.category] ==
                            _categoryManager.selectedCategory)
                    .toList();

                final groupedNotifications =
                    _groupNotifications(notificationsByCategory);

                devtools
                    .log("Notifications list is this ${groupedNotifications}");

                return ListView(
                  children: groupedNotifications.entries.expand((entry) {
                    final sectionTitle = entry.key;
                    final sectionNotifications = entry.value;

                    return [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          sectionTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...sectionNotifications.asMap().entries.map((entry) {
                        final index = entry.key;
                        final notification = entry.value;
                        final hasConfirmed = notification.isRead &&
                            notification.questionsAndAnswers.isNotEmpty;

                        if (hasConfirmed) {
                          return Container();
                        }

                        return Dismissible(
                          key: Key(notification.id.toString()),
                          background: Container(
                            color:
                                Colors.blue, // Background color for left swipe
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(
                                left: 16.0), // Padding from the left edge
                            child: Icon(Icons.info,
                                color: Colors.white), // Icon for left swipe
                          ),
                          secondaryBackground: Container(
                            color:
                                Colors.red, // Background color for right swipe
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(
                                right: 16.0), // Padding from the right edge
                            child: Icon(Icons.delete,
                                color: Colors.white), // Icon for right swipe
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
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
                            }
                            return false; // Only confirm dismissal for right swipe
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              _removeNotificationByIndex(index);
                            }
                          },
                          child: Card(
                            elevation: 2.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 20.0), // Increased margin
                            child: Padding(
                              padding: EdgeInsets.all(
                                  12.5), // Added padding inside the card
                              child: ListTile(
                                contentPadding: EdgeInsets
                                    .zero, // Remove default padding of ListTile
                                title: Text(
                                  notification.title,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                        height:
                                            8.0), // Add space between message and timestamp
                                    Text(notification.message),
                                    SizedBox(
                                        height:
                                            4.0), // Add space before timestamp
                                    Text(
                                      _formatTimeDifference(
                                          notification.timestamp),
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: Visibility(
                                  visible: notification
                                      .questionsAndAnswers.isNotEmpty,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          await _handleConfirmation(
                                              notification);
                                        },
                                        child: Text("Confirm"),
                                      ),
                                      SizedBox(
                                          width:
                                              8.0), // Add space between buttons
                                      TextButton(
                                        onPressed: () async {
                                          await _handleNegation(notification);
                                        },
                                        child: Text("Negate"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList()
                    ];
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void main() {
    runApp(MaterialApp(
      home: ShowNotifications(user: widget.user),
    ));
  }
}
