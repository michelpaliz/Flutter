import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/utilities/utilities.dart';

class NotificationFormats {
  late NotificationUser _notificationUser;

  NotificationUser whenCreatingGroup(Group group, User admin) {
    final congratulatoryTitle = 'Congratulations!';
    final congratulatoryMessage = 'You created the group: ${group.groupName}';
    _notificationUser = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      ownerId: admin.id,
      title: congratulatoryTitle,
      message: congratulatoryMessage,
      timestamp: DateTime.now(),
      questionsAndAnswers: {}, // Initialize as an empty map
      groupId: group.id,
      isRead: false,
      type: NotificationType.update, // Set type
      priority: PriorityLevel.medium, // Default priority
    );
    return _notificationUser;
  }

  NotificationUser whenEditingGroup(Group group, User admin) {
    final title = 'You have edited this group!';
    final description = 'You edited the group: ${group.groupName}';
    final editNotification = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      ownerId: admin.id,
      title: title,
      message: description,
      timestamp: DateTime.now(),
      questionsAndAnswers: {}, // Initialize as an empty map
      groupId: group.id,
      isRead: false,
      type: NotificationType.update, // Set type
      priority: PriorityLevel.medium, // Default priority
    );
    return editNotification;
  }

  NotificationUser createGroupInvitation(Group group, User user) {
    final userNotificationTitle = 'Join ${group.groupName}';
    final userNotificationMessage =
        'You have been invited to join the group: ${group.groupName}';
    final userNotificationQuestion = 'Would you like to join this group?';

    final userNotification = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      ownerId: user.id,
      title: userNotificationTitle,
      message: userNotificationMessage,
      timestamp: DateTime.now(),
      questionsAndAnswers: {
        userNotificationQuestion: ''
      }, // Initialize map with a question
      groupId: group.id,
      isRead: false,
      type: NotificationType.alert, // Set type to alert
      priority: PriorityLevel.high, // Set priority to high
    );

    user.notifications.add(userNotification);
    user.hasNewNotifications = true;

    return userNotification;
  }

  NotificationUser newUserHasBeenAdded(Group group, User user) {
    final userNotificationTitle = '${group.groupName}';
    final userNotificationMessage =
        'You have joined the group: ${group.groupName}';

    final userNotification = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      ownerId: user.id,
      title: userNotificationTitle,
      message: userNotificationMessage,
      timestamp: DateTime.now(),
      questionsAndAnswers: {}, // Initialize as an empty map
      groupId: group.id,
      isRead: false,
      type: NotificationType.message, // Set type to message
      priority: PriorityLevel.low, // Set priority to low
    );

    user.notifications.add(userNotification);
    user.hasNewNotifications = true;

    return userNotification;
  }

  bool isDuplicateNotification(
      List<NotificationUser> notifications, NotificationUser newNotification) {
    return notifications.any((notification) =>
        notification.title == newNotification.title &&
        notification.message == newNotification.message &&
        notification.ownerId == newNotification.ownerId);
  }
}
