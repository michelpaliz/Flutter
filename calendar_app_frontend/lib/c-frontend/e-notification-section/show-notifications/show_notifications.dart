import 'package:calendar_app_frontend/a-models/notification_model/notification_user.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/notification/notification_services.dart';
import 'package:calendar_app_frontend/b-backend/api/user/user_services.dart';
import 'package:calendar_app_frontend/c-frontend/e-notification-section/enum/broad_category.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/notification/notification_management.dart';
import 'package:calendar_app_frontend/d-stateManagement/user/user_management.dart';
import 'package:calendar_app_frontend/e-drawer-style-menu/main_scaffold.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
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
    final notifMgmt = Provider.of<NotificationManagement>(
      context,
      listen: false,
    );

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
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return MainScaffold(
      title: '', // we use titleWidget instead
      titleWidget: Text(
        loc.notifications,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
      body: StreamBuilder<List<NotificationUser>>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(child: Text(loc.zeroNotifications));
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                      }),
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
}
