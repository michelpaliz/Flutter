import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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
      default:
        return fallbackMessage;
    }
  }
}
