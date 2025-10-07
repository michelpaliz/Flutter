import 'package:flutter/material.dart';
import 'package:hexora/a-models/notification_model/notification_user.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/core/group/domain/group_domain.dart';
import 'package:hexora/b-backend/login_user/user/domain/user_domain.dart';
import 'package:hexora/b-backend/notification/domain/notification_domain.dart';
import 'package:hexora/b-backend/notification/notification_api_client.dart';
import 'package:hexora/c-frontend/f-notification-section/enum/broad_category.dart';
import 'package:hexora/e-drawer-style-menu/main_scaffold.dart';
import 'package:hexora/l10n/app_localizations.dart';
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

  bool _clearing = false; // prevent double taps while clearing

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userMgmt = Provider.of<UserDomain>(context, listen: false);
    final groupMgmt = Provider.of<GroupDomain>(context, listen: false);
    final notifMgmt = Provider.of<NotificationDomain>(context, listen: false);

    _notificationController = NotificationController(
      userDomain: userMgmt,
      groupDomain: groupMgmt,
      notificationDomain: notifMgmt,
      notificationService: NotificationApiClient(),
    );

    _notificationsStream = notifMgmt.notificationStream;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationController.fetchAndUpdateNotifications(widget.user);
    });
  }

  Future<void> _confirmAndClearAll(AppLocalizations loc) async {
    if (_clearing) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.clearAll),
        content: Text(loc.clearAllConfirm), // “Remove all notifications?”
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.confirm),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _clearing = true);
      try {
        await _notificationController.removeAllNotifications(widget.user);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.clearedAllNotifications)),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.error}: $e')),
        );
      } finally {
        if (mounted) setState(() => _clearing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return MainScaffold(
      title: '', // we use titleWidget instead
      titleWidget: Row(
        children: [
          Text(
            loc.notifications,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          Tooltip(
            message: loc.clearAll,
            child: IconButton(
              icon: _clearing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.clear_all),
              onPressed: _clearing ? null : () => _confirmAndClearAll(loc),
            ),
          ),
        ],
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
