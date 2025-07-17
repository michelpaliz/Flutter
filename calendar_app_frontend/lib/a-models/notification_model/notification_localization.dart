import 'package:calendar_app_frontend/a-models/notification_model/notification_user.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';

extension NotificationLocalization on NotificationUser {
  String getLocalizedTitle(AppLocalizations loc) {
    switch (titleKey) {
      case 'notification.groupCreation.title':
        return loc.notificationGroupCreationTitle;
      case 'notification.joinedGroup.title':
        return loc.notificationJoinedGroupTitle;
      case 'notification.invitation.title':
        return loc.notificationInvitationTitle;
      case 'notification.invitationDenied.title':
        return loc.notificationInvitationDeniedTitle;
      case 'notification.userAccepted.title':
        return loc.notificationUserAcceptedTitle;
      case 'notification.groupEdited.title':
        return loc.notificationGroupEditedTitle;
      case 'notification.groupDeleted.title':
        return loc.notificationGroupDeletedTitle;
      case 'notification.userRemoved.title':
        return loc.notificationUserRemovedTitle;
      case 'notification.adminUserRemoved.title':
        return loc.notificationAdminUserRemovedTitle;
      case 'notification.userLeft.title':
        return loc.notificationUserLeftTitle;
      case 'notification.groupUpdate.title':
        return loc.notificationGroupUpdateTitle;
      case 'notification.groupDeletedAll.title':
        return loc.notificationGroupDeletedAllTitle;

      // 🔹 Event-related titles
      case 'notification.event.reminder.title':
        return loc.notificationEventReminderTitle;
      case 'notification.event.created.title':
        return loc.notificationEventCreatedTitle;
      case 'notification.event.updated.title':
        return loc.notificationEventUpdatedTitle;
      case 'notification.event.deleted.title':
        return loc.notificationEventDeletedTitle;
      case 'notification.recurrenceAdded.title':
        return loc.notificationRecurrenceAddedTitle;
      case 'notification.eventMarkedDone.title':
        return loc.notificationEventMarkedDoneTitle;
      case 'notification.eventReopened.title':
        return loc.notificationEventReopenedTitle;

      default:
        return fallbackTitle;
    }
  }

  String getLocalizedMessage(AppLocalizations loc) {
    switch (messageKey) {
      case 'notification.groupCreation.message':
        return loc.notificationGroupCreationMessage(args['groupName'] ?? '');
      case 'notification.joinedGroup.message':
        return loc.notificationJoinedGroupMessage(args['groupName'] ?? '');
      case 'notification.invitation.message':
        return loc.notificationInvitationMessage(args['groupName'] ?? '');
      case 'notification.invitationDenied.message':
        return loc.notificationInvitationDeniedMessage(
          args['userName'] ?? '',
          args['groupName'] ?? '',
        );
      case 'notification.userAccepted.message':
        return loc.notificationUserAcceptedMessage(
          args['userName'] ?? '',
          args['groupName'] ?? '',
        );
      case 'notification.groupEdited.message':
        return loc.notificationGroupEditedMessage(args['groupName'] ?? '');
      case 'notification.groupDeleted.message':
        return loc.notificationGroupDeletedMessage(args['groupName'] ?? '');
      case 'notification.userRemoved.message':
        return loc.notificationUserRemovedMessage(
          args['groupName'] ?? '',
          args['adminName'] ?? '',
        );
      case 'notification.adminUserRemoved.message':
        return loc.notificationAdminUserRemovedMessage(
          args['userName'] ?? '',
          args['groupName'] ?? '',
        );
      case 'notification.userLeft.message':
        return loc.notificationUserLeftMessage(
          args['userName'] ?? '',
          args['groupName'] ?? '',
        );
      case 'notification.groupUpdate.message':
        return loc.notificationGroupUpdateMessage(
          args['editorName'] ?? '',
          args['groupName'] ?? '',
        );
      case 'notification.groupDeletedAll.message':
        return loc.notificationGroupDeletedAllMessage(args['groupName'] ?? '');

      // 🔹 Event-related messages
      case 'notification.event.reminder.message':
        return loc.notificationEventReminderMessage(args['eventTitle'] ?? '');
      case 'notification.event.created.message':
        return loc.notificationEventCreatedMessage(args['eventTitle'] ?? '');
      case 'notification.event.updated.message':
        return loc.notificationEventUpdatedMessage(args['eventTitle'] ?? '');
      case 'notification.event.deleted.message':
        return loc.notificationEventDeletedMessage(args['eventTitle'] ?? '');
      case 'notification.recurrenceAdded.message':
        return loc.notificationRecurrenceAddedMessage(args['title'] ?? '');
      case 'notification.eventMarkedDone.message':
        return loc.notificationEventMarkedDoneMessage(
          args['eventTitle'] ?? '',
          args['userName'] ?? '',
        );
      case 'notification.eventReopened.message':
        return loc.notificationEventReopenedMessage(
          args['eventTitle'] ?? '',
          args['userName'] ?? '',
        );

      default:
        return fallbackMessage;
    }
  }
}
