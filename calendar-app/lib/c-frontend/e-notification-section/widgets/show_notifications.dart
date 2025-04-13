import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/utilities/enums/broad_category.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/notification_conroller.dart';

class ShowNotifications extends StatefulWidget {
  final User user;
  const ShowNotifications({required this.user, Key? key}) : super(key: key);

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  final BroadCategoryManager _categoryManager = BroadCategoryManager();
  late BroadCategory _selectedCategory = BroadCategory.group;

  late Stream<List<NotificationUser>> _notificationsStream;
  late User _currentUser = widget.user;

  late UserManagement _userManagement;
  late NotificationManagement _notificationManagement;
  late GroupManagement _groupManagement;

  final UserService _userService = UserService();
  late NotificationController _notificationController;

  @override
  void initState() {
    super.initState();
    _initializeStream();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchAndUpdateNotifications();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
    _notificationManagement =
        Provider.of<NotificationManagement>(context, listen: false);

    _notificationController = NotificationController(
      userManagement: _userManagement,
      groupManagement: _groupManagement,
      notificationManagement: _notificationManagement,
      userService: _userService,
    );

    if (_userManagement.user != null) {
      _currentUser = _userManagement.user!;
      _notificationsStream = _notificationManagement.notificationStream;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchAndUpdateNotifications();
      });
    } else {
      devtools.log("Current User is null");
    }
  }

  void _initializeStream() {
    _notificationsStream = Stream.empty();
  }

  Future<void> _fetchAndUpdateNotifications() async {
    try {
      if (_currentUser.notifications!.isNotEmpty) {
        final fetchedNotifications =
            await _userService.getNotificationsByUser(_currentUser.userName);

        fetchedNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _notificationManagement.updateNotificationStream(fetchedNotifications);
      } else {
        _notificationManagement.updateNotificationStream([]);
      }
    } catch (error) {
      devtools.log('Error: $error');
    }
  }

  Future<void> _removeAllNotifications() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Removal"),
        content: Text("Are you sure you want to remove all notifications?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Yes")),
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("No")),
        ],
      ),
    );

    if (confirm == true) {
      await _notificationController.removeAllNotifications(_currentUser);
      if (mounted) setState(() {});
    }
  }

  Future<void> _removeNotificationByIndex(int index) async {
    await _notificationController.removeNotificationByIndex(index);
  }

  String _formatTimeDifference(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return 'Last 30 days';
    return DateFormat('MMM d, yyyy').format(dateTime);
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
      final diff = now.difference(notification.timestamp);
      if (diff.inDays < 1)
        grouped['Recent']!.add(notification);
      else if (diff.inDays < 7)
        grouped['Last 7 days']!.add(notification);
      else if (diff.inDays < 30)
        grouped['Last 30 days']!.add(notification);
      else
        grouped['Older']!.add(notification);
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
          )
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: BroadCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: isSelected ? Colors.teal : Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = category;
                        _categoryManager.filterNotifications(category);
                      });
                    },
                    child:
                        Text(category.toString().split('.').last.toUpperCase()),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<NotificationUser>>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData || snapshot.data!.isEmpty)
                  return Center(child: Text('No notifications available.'));

                final notifications = snapshot.data!;
                final filtered = notifications.where((ntf) {
                  return _categoryManager.selectedCategory == null ||
                      _categoryManager.categoryMapping[ntf.category] ==
                          _categoryManager.selectedCategory;
                }).toList();

                final grouped = _groupNotifications(filtered);

                return ListView(
                  children: grouped.entries.expand((entry) {
                    return [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...entry.value.asMap().entries.map((entry) {
                        final index = entry.key;
                        final notification = entry.value;
                        final isActionable =
                            notification.questionsAndAnswers.isNotEmpty &&
                                !notification.isRead;

                        return Dismissible(
                          key: Key(notification.id),
                          background: _swipeActionLeft(),
                          secondaryBackground: _swipeActionRight(),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              return await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text("Confirm"),
                                  content: Text("Remove this notification?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text("Yes")),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text("No")),
                                  ],
                                ),
                              );
                            }
                            return false;
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              _removeNotificationByIndex(index);
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(12.5),
                              child: ListTile(
                                title: Text(notification.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(notification.message),
                                    SizedBox(height: 4),
                                    Text(
                                      _formatTimeDifference(
                                          notification.timestamp),
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: isActionable
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                _notificationController
                                                    .handleConfirmation(
                                                        notification),
                                            child: Text("Confirm"),
                                          ),
                                          SizedBox(width: 8),
                                          TextButton(
                                            onPressed: () =>
                                                _notificationController
                                                    .handleNegation(
                                                        notification),
                                            child: Text("Negate"),
                                          ),
                                        ],
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
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

  Widget _swipeActionLeft() => Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 16),
        child: Icon(Icons.info, color: Colors.white),
      );

  Widget _swipeActionRight() => Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      );
}
