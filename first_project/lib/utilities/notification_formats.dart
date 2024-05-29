import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';

class NotificationFormats {
  late NotificationUser _notificationUser;

  // NotificationFormats(this._notificationUser);

  NotificationUser whenCreatingGroup(Group group, User admin) {
    final congratulatoryTitle = 'Congratulations!';
    final congratulatoryMessage = 'You created the group: ${group.groupName}';
    _notificationUser = NotificationUser(
      id: group.id,
      ownerId: admin.id,
      title: congratulatoryTitle,
      message: congratulatoryMessage,
      timestamp: DateTime.now(),
      hasQuestion: false,
      question: '',
    );
    return _notificationUser;
  }

  NotificationUser whenEditingGroup(Group group, User admin) {
    final title = 'You have edited this group !';
    final description = 'You edited the group: ${group.groupName}';
    final editNotification = NotificationUser(
      id: group.id,
      ownerId: admin.id,
      title: title,
      message: description,
      timestamp: DateTime.now(),
      hasQuestion: false,
      question: '',
    );
    return editNotification;
  }

  NotificationUser createGroupInvitation(Group group, User user) {
    // Create invitation notification for the user
    final userNotificationTitle = 'Join ${group.groupName}';
    final userNotificationMessage =
        'You have been invited to join the group: ${group.groupName}';
    final userNotificationQuestion = 'Would you like to join this group ?';

    // Create notification for the user
    final userNotification = NotificationUser(
      id: group.id,
      ownerId: user.id,
      title: userNotificationTitle,
      message: userNotificationMessage,
      timestamp: DateTime.now(),
      hasQuestion: true,
      question: userNotificationQuestion,
    );

    // Add notification to the user's list
    user.notifications.add(userNotification);
    user.hasNewNotifications = true;

    // Update user document in Firestore
    return userNotification;
    // }
  }
}
