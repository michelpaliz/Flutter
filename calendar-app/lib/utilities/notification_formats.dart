import 'package:first_project/a-models/group.dart';
import 'package:first_project/a-models/notification_user.dart';
import 'package:first_project/a-models/user.dart';
import 'package:first_project/utilities/utilities.dart';

class NotificationFormats {
  late NotificationUser _notificationUser;

  NotificationUser whenCreatingGroup(Group group, User admin) {
    final congratulatoryTitle = 'Congratulations!';
    final congratulatoryMessage = 'You created the group: ${group.name}';
    _notificationUser = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      senderId: admin.id,
      recipientId: admin.id,
      title: congratulatoryTitle,
      message: congratulatoryMessage,
      timestamp: DateTime.now(),
      questionsAndAnswers: {}, // Initialize as an empty map
      groupId: group.id,
      isRead: false,
      type: NotificationType.update, // Set type
      priority: PriorityLevel.medium, // Default priority
      category: Category.groupCreation, // Set category
    );
    return _notificationUser;
  }

  NotificationUser whenEditingGroup(Group group, User admin) {
    final title = 'You have edited this group!';
    final description = 'You edited the group: ${group.name}';
    final editNotification = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      senderId: admin.id,
      recipientId: admin.id,
      title: title,
      message: description,
      timestamp: DateTime.now(),
      questionsAndAnswers: {}, // Initialize as an empty map
      groupId: group.id,
      isRead: false,
      type: NotificationType.update, // Set type
      priority: PriorityLevel.medium, // Default priority
      category: Category.groupUpdate, // Set category
    );
    return editNotification;
  }

  NotificationUser createGroupInvitation(Group group, User member) {
    final userNotificationTitle = 'Join ${group.name}';
    final userNotificationMessage =
        'You have been invited to join the group: ${group.name}';
    final userNotificationQuestion = 'Would you like to join this group?';

    final userNotification = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      senderId: group.ownerId,
      recipientId: member.id,
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
      category: Category.groupInvitation, // Set category
    );

    member.notifications.add(userNotification);
    member.hasNewNotifications = true;

    return userNotification;
  }

  NotificationUser welcomeNewUserGroup(Group group, User member) {
    final userNotificationTitle = '${group.name}';
    final userNotificationMessage =
        'You have joined the group: ${group.name}';

    final userNotification = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      senderId: group.ownerId,
      recipientId: member.id,
      title: userNotificationTitle,
      message: userNotificationMessage,
      timestamp: DateTime.now(),
      questionsAndAnswers: {}, // Initialize as an empty map
      groupId: group.id,
      isRead: false,
      type: NotificationType.message, // Set type to message
      priority: PriorityLevel.low, // Set priority to low
      category: Category.groupUpdate, // Set category
    );

    member.notifications.add(userNotification);
    member.hasNewNotifications = true;

    return userNotification;
  }

  NotificationUser notificationUserDenyGroup(Group group, User member) {
    final userNotificationTitle = '${group.name}';
    final userNotificationMessage =
        'You have denied the invitation to join the group: ${group.name}';

    final userNotification = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      senderId: group.ownerId,
      recipientId: member.id,
      title: userNotificationTitle,
      message: userNotificationMessage,
      timestamp: DateTime.now(),
      questionsAndAnswers: {}, // Initialize as an empty map
      groupId: group.id,
      isRead: false,
      type: NotificationType
          .alert, // Set type to warning (or choose another type if more appropriate)
      priority:
          PriorityLevel.medium, // Set priority to medium (or adjust as needed)
      category: Category.groupUpdate, // Set category
    );

    member.notifications.add(userNotification);
    member.hasNewNotifications = true;

    return userNotification;
  }

  NotificationUser userRemovedFromGroup(Group group, User member, User admin) {
    final userNotificationTitle = 'User Removed from Group';
    final userNotificationMessage =
        '${member.userName} has been removed from the group: ${group.name}';

    final adminNotification = NotificationUser(
      id: Utilities.generateRandomId(10), // Generate a new ID
      senderId: admin.id,
      recipientId: member.id,
      title: userNotificationTitle,
      message: userNotificationMessage,
      timestamp: DateTime.now(),
      questionsAndAnswers: {}, // Initialize as an empty map
      groupId: group.id,
      isRead: false,
      type: NotificationType.alert, // Set type to alert
      priority: PriorityLevel.high, // Set priority to high
      category: Category.userRemoval, // Set category
    );

    admin.notifications.add(adminNotification);
    admin.hasNewNotifications = true;

    return adminNotification;
  }

  NotificationUser notifyUserRemoval(Group group, User member, User admin) {
  final userNotificationTitle = 'User Removed from Group';
  final userNotificationMessage =
      'You have been removed from the group: ${group.name} by ${admin.userName}';

  final recipientNotification = NotificationUser(
    id: Utilities.generateRandomId(10), // Generate a new ID
    senderId: admin.id,
    recipientId: member.id,
    title: userNotificationTitle,
    message: userNotificationMessage,
    timestamp: DateTime.now(),
    questionsAndAnswers: {}, // Initialize as an empty map
    groupId: group.id,
    isRead: false,
    type: NotificationType.alert, // Set type to alert
    priority: PriorityLevel.high, // Set priority to high
    category: Category.userRemoval, // Set category
  );

  member.notifications.add(recipientNotification);
  member.hasNewNotifications = true;

  return recipientNotification;
}


  NotificationUser eventReminder(DateTime eventDate, User user) {
    final userNotificationTitle = 'Upcoming Event Reminder';
    final userNotificationMessage =
        'Don\'t forget about your event on ${eventDate.toLocal()}';

    final userNotification = NotificationUser(
      id: Utilities.generateRandomId(10),
      senderId: user.id,
      recipientId: user.id,
      title: userNotificationTitle,
      message: userNotificationMessage,
      timestamp: DateTime.now(),
      questionsAndAnswers: {},
      groupId: null,
      isRead: false,
      type: NotificationType.reminder,
      priority: PriorityLevel.high,
      category: Category.eventReminder,
    );

    user.notifications.add(userNotification);
    user.hasNewNotifications = true;

    return userNotification;
  }

  //   NotificationUser taskUpdate(String taskName, User user) {
  //   final userNotificationTitle = 'Task Updated';
  //   final userNotificationMessage = 'The task "$taskName" has been updated.';

  //   final userNotification = NotificationUser(
  //     id: Utilities.generateRandomId(10),
  //     ownerId: user.id,
  //     title: userNotificationTitle,
  //     message: userNotificationMessage,
  //     timestamp: DateTime.now(),
  //     questionsAndAnswers: {},
  //     groupId: null,
  //     isRead: false,
  //     type: NotificationType.update,
  //     priority: PriorityLevel.medium,
  //     category: Category.taskUpdate,
  //   );

  //   user.notifications.add(userNotification);
  //   user.hasNewNotifications = true;

  //   return userNotification;
  // }

  static bool isDuplicateNotification(
      List<NotificationUser> notifications, NotificationUser newNotification) {
    return notifications.any((notification) =>
        notification.id == newNotification.id); // Check all relevant fields
  }
}
