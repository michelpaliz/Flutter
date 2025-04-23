import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/node_services/notification_services.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
import 'package:first_project/c-frontend/e-notification-section/enum/broad_category.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/notification_controller.dart';

class ShowNotifications extends StatefulWidget {
  final User user;
  const ShowNotifications({required this.user, Key? key}) : super(key: key);

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  final BroadCategoryManager _categoryManager = BroadCategoryManager();
  BroadCategory? _selectedCategory;

  late Stream<List<NotificationUser>> _notificationsStream;
  late User _currentUser = widget.user;

  late UserManagement _userManagement;
  late NotificationManagement _notificationManagement;
  late GroupManagement _groupManagement;

  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();
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
      notificationService: _notificationService,
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
    _selectedCategory = null; // no filter at start
  }

  Future<void> _fetchAndUpdateNotifications() async {
    try {
      final fetched = await _notificationService
          .getNotificationsForUser(_currentUser.userName);
      fetched.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _notificationManagement.updateNotificationStream(fetched);
    } catch (error) {
      devtools.log('Error fetching notifications: $error');
    }
  }

  Future<void> _removeAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
      setState(() {});
    }
  }

  Future<void> _removeNotificationByIndex(int index) async {
    await _notificationController.removeNotificationByIndex(index);
  }

  String _formatTimeDifference(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return 'Last 30 days';
    return DateFormat('MMM d, yyyy').format(dt);
  }

  Map<String, List<NotificationUser>> _groupNotifications(
      List<NotificationUser> list) {
    final now = DateTime.now();
    final grouped = {
      'Recent': <NotificationUser>[],
      'Last 7 days': <NotificationUser>[],
      'Last 30 days': <NotificationUser>[],
      'Older': <NotificationUser>[],
    };
    for (var ntf in list) {
      final d = now.difference(ntf.timestamp);
      if (d.inDays < 1)
        grouped['Recent']!.add(ntf);
      else if (d.inDays < 7)
        grouped['Last 7 days']!.add(ntf);
      else if (d.inDays < 30)
        grouped['Last 30 days']!.add(ntf);
      else
        grouped['Older']!.add(ntf);
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
              onPressed: _removeAllNotifications)
        ],
      ),
      body: Column(
        children: [
          // —— CATEGORY FILTER BAR ——
          StreamBuilder<List<NotificationUser>>(
            stream: _notificationsStream,
            builder: (context, snap) {
              final notifications = snap.data ?? [];
              // derive only used broad categories (int → Category → BroadCategory)
              final usedCats = notifications
                  .map((ntf) => _categoryManager.categoryMapping[
                      ntf.category]) // ntf.category is already Category
                  .whereType<BroadCategory>() // drop any null mappings
                  .toSet();

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: usedCats.map((cat) {
                    final selected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 12),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selected ? Colors.teal : Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCategory = cat;
                            _categoryManager.filterNotifications(cat);
                          });
                        },
                        child:
                            Text(cat.toString().split('.').last.toUpperCase()),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          // —— NOTIFICATION LIST ——
          Expanded(
            child: StreamBuilder<List<NotificationUser>>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                final data = snapshot.data ?? [];
                if (data.isEmpty)
                  return Center(child: Text('No notifications available.'));

                // filter by selected broad category
                final filtered = data.where((ntf) {
                  // if no filter is selected, include everything
                  if (_selectedCategory == null) return true;

                  // rawCat is already a Category enum
                  final rawCat = ntf.category;

                  // map it to a BroadCategory and compare
                  return _categoryManager.categoryMapping[rawCat] ==
                      _selectedCategory;
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
                      ...entry.value.asMap().entries.map((e) {
                        final idx = e.key;
                        final ntf = e.value;
                        final actionable =
                            ntf.questionsAndAnswers.isNotEmpty && !ntf.isRead;

                        return Dismissible(
                          key: Key(ntf.id),
                          background: _swipeActionLeft(),
                          secondaryBackground: _swipeActionRight(),
                          confirmDismiss: (dir) async {
                            if (dir == DismissDirection.endToStart) {
                              return await showDialog<bool>(
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
                          onDismissed: (_) => _removeNotificationByIndex(idx),
                          child: Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            child: ListTile(
                              title: Text(ntf.title,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Text(ntf.message),
                                  SizedBox(height: 4),
                                  Text(_formatTimeDifference(ntf.timestamp),
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                              trailing: actionable
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              _notificationController
                                                  .handleConfirmation(ntf),
                                          child: Text("Confirm"),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              _notificationController
                                                  .handleNegation(ntf),
                                          child: Text("Negate"),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
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
