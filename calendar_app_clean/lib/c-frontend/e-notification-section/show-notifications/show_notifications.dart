import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/node_services/notification_services.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
import 'package:first_project/c-frontend/e-notification-section/enum/broad_category.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../controllers/notification_controller.dart';
import 'utils/notification_grouping.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_filter_bar.dart';

class ShowNotifications extends StatefulWidget {
  final User user;
  const ShowNotifications({required this.user, Key? key}) : super(key: key);

  @override
  State<ShowNotifications> createState() => _ShowNotificationsState();
}

class _ShowNotificationsState extends State<ShowNotifications> {
  late NotificationController _notificationController;
  late Stream<List<NotificationUser>> _notificationsStream;
  BroadCategory? _selectedCategory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userMgmt = Provider.of<UserManagement>(context, listen: false);
    final groupMgmt = Provider.of<GroupManagement>(context, listen: false);
    final notifMgmt =
        Provider.of<NotificationManagement>(context, listen: false);

    _notificationController = NotificationController(
      userManagement: userMgmt,
      groupManagement: groupMgmt,
      notificationManagement: notifMgmt,
      userService: UserService(),
      notificationService: NotificationService(),
    );

    _notificationsStream = notifMgmt.notificationStream;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationController.fetchAndUpdateNotifications(widget.user);
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // 👈 Localization reference

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.notifications), // 👈 From your translations
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () async {
              final confirmed = await _confirmClearAll(context, loc);
              if (confirmed) {
                await _notificationController
                    .removeAllNotifications(widget.user);
              }
            },
          )
        ],
      ),
      body: StreamBuilder<List<NotificationUser>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(child: Text(loc.zeroNotifications)); // 👈 Localized
          }

          final filtered = _selectedCategory == null
              ? notifications
              : notifications.where((ntf) {
                  final mapping = BroadCategoryManager().categoryMapping;
                  return mapping[ntf.category] == _selectedCategory;
                }).toList();

          final grouped = groupNotificationsByTime(filtered, loc);

          return Column(
            children: [
              NotificationFilterBar(
                notifications: notifications,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
              Expanded(
                child: ListView(
                  children: grouped.entries.expand((entry) {
                    return [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...entry.value.asMap().entries.map((e) {
                        final ntf = e.value;
                        return NotificationCard(
                          notification: ntf,
                          onDelete: () => _notificationController
                              .removeNotificationByIndex(e.key),
                          onConfirm: () =>
                              _notificationController.handleConfirmation(ntf),
                          onNegate: () =>
                              _notificationController.handleNegation(ntf),
                        );
                      })
                    ];
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _confirmClearAll(
      BuildContext context, AppLocalizations loc) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(loc.confirmation), // "Confirmation"
            content: Text(loc.removeConfirmation), // "Confirm to remove"
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(loc.confirm), // "Confirm"
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(loc.cancel), // "Cancel"
              ),
            ],
          ),
        ) ??
        false;
  }
}
