import 'package:first_project/a-models/notification_model/notification_localization.dart';
import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/c-frontend/e-notification-section/show-notifications/utils/notification_formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationCard extends StatelessWidget {
  final NotificationUser notification;
  final VoidCallback onDelete;
  final VoidCallback? onConfirm;
  final VoidCallback? onNegate;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onDelete,
    this.onConfirm,
    this.onNegate,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final actionable =
        notification.questionsAndAnswers.isNotEmpty && !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      background: swipeActionLeft(loc),
      secondaryBackground: swipeActionRight(loc),
      confirmDismiss: (_) => _confirmDismiss(context, loc),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: ListTile(
          title: Text(
            notification.getLocalizedTitle(loc),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(notification.getLocalizedMessage(loc)),
              SizedBox(height: 4),
              Text(
                formatTimeDifference(notification.timestamp, context),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          trailing: actionable
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: onConfirm,
                      child: Text(loc.confirm), // ✅ Localized
                    ),
                    TextButton(
                      onPressed: onNegate,
                      child:
                          Text(loc.cancel), // ✅ Localized as "Negate" fallback
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(
      BuildContext context, AppLocalizations loc) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(loc.confirmation),
            content: Text(loc.removeConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(loc.confirm),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(loc.cancel),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget swipeActionLeft(AppLocalizations loc) => Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: Icon(Icons.info, color: Colors.white),
      );

  Widget swipeActionRight(AppLocalizations loc) => Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      );
}
