import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/notification_model/notification_user.dart';
import 'package:first_project/a-models/notification_model/userInvitation_status.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/node_services/user_services.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/utilities/notification_formats.dart';

class NotificationController {
  final UserManagement userManagement;
  final GroupManagement groupManagement;
  final NotificationManagement notificationManagement;
  final UserService userService;

  NotificationController({
    required this.userManagement,
    required this.groupManagement,
    required this.notificationManagement,
    required this.userService,
  });

  Future<void> handleConfirmation(NotificationUser notification) async {
    if (notification.questionsAndAnswers.isNotEmpty) {
      try {
        final groupFetched = await groupManagement.groupService
            .getGroupById(notification.groupId!);
        final invitedUsers = groupFetched.invitedUsers;

        if (invitedUsers == null) {
          devtools.log('Invited users not found.');
          return;
        }

        await _processInvitationConfirmation(
            notification, invitedUsers, groupFetched);
      } catch (e) {
        devtools.log('Error fetching group: $e');
      }
    }
  }

  Future<void> _processInvitationConfirmation(
    NotificationUser notification,
    Map<String, UserInviteStatus> invitedUsers,
    Group group,
  ) async {
    User userInvited = await userService.getUserById(notification.recipientId);

    final inviteStatus = invitedUsers[userInvited.userName];
    inviteStatus!.invitationAnswer = true;
    invitedUsers[userInvited.userName] = inviteStatus;

    group.userIds.add(userInvited.id);
    group.userRoles[userInvited.userName] = inviteStatus.role;
    userInvited.groupIds.add(group.id);

    await _updateGroupAndSendNotifications(
        notification, userInvited, group, invitedUsers);
  }

  Future<void> _updateGroupAndSendNotifications(
    NotificationUser notification,
    User userInvited,
    Group group,
    Map<String, UserInviteStatus> invitedUsers,
  ) async {
    await userManagement.updateUser(userInvited);
    await groupManagement.updateGroup(
        group, userManagement, notificationManagement, invitedUsers);

    final notificationFormat = NotificationFormats();
    NotificationUser joinedNotification =
        notificationFormat.welcomeNewUserGroup(group, userInvited);

    bool notificationAdded = await notificationManagement.addNotificationToDB(
        joinedNotification, userManagement);

    if (notificationAdded) {
      await _sendNotificationToAdmin(notification, userInvited, true);

      await notificationManagement.removeNotificationById(
          notification.id, userManagement);
    }
  }

  Future<void> handleNegation(NotificationUser notification) async {
    if (notification.groupId != null &&
        notification.questionsAndAnswers.isNotEmpty) {
      final group = await groupManagement.groupService
          .getGroupById(notification.groupId!);
      final invitedUsers = group.invitedUsers;

      User userInvited =
          await userService.getUserById(notification.recipientId);

      if (userInvited.notifications != null) {
        for (String notificationId in userInvited.notifications!) {
          NotificationUser? ntf = await notificationManagement
              .notificationService
              .getNotificationById(notificationId);

          if (ntf.groupId == group.id && ntf.questionsAndAnswers.isNotEmpty) {
            String questionKey = ntf.questionsAndAnswers.keys.first;

            ntf.questionsAndAnswers.update(
              questionKey,
              (value) => 'Has denied the invitation',
            );

            await notificationManagement.notificationService
                .updateNotification(ntf);
          }
        }
      }

      await userManagement.updateUser(userInvited);
      await _processInvitationNegation(notification, invitedUsers!, group);
    }
  }

  Future<void> _processInvitationNegation(
    NotificationUser notification,
    Map<String, UserInviteStatus> invitedUsers,
    Group group,
  ) async {
    User userInvited = await userService.getUserById(notification.recipientId);
    final currentUserName = userInvited.userName;
    final inviteStatus = invitedUsers[currentUserName];

    if (inviteStatus != null) {
      inviteStatus.invitationAnswer = false;
      invitedUsers[currentUserName] = inviteStatus;
      group.invitedUsers = invitedUsers;

      await groupManagement.groupService.updateGroup(group);

      final notificationFormat = NotificationFormats();
      NotificationUser denyNotification =
          notificationFormat.notificationUserDenyGroup(group, userInvited);

      bool notificationAdded = await notificationManagement.addNotificationToDB(
          denyNotification, userManagement);

      bool notificationRemoved = await notificationManagement
          .removeNotificationById(notification.id, userManagement);

      if (notificationAdded && notificationRemoved) {
        await _sendNotificationToAdmin(notification, userInvited, false);
      }
    }
  }

  Future<void> removeNotificationByIndex(int index) async {
    await notificationManagement.removeNotificationByIndex(
        index, userManagement);
  }

  Future<void> removeAllNotifications(User user) async {
    notificationManagement.clearNotifications();
    user.notifications?.clear();
    await userManagement.userService.updateUser(user);
  }

  Future<void> _sendNotificationToAdmin(NotificationUser originalNotification,
      User fromUser, bool accepted) async {
    final ntOwner = NotificationUser(
      id: '', // leave it blank; DB should assign this
      senderId: originalNotification.senderId,
      recipientId: originalNotification.senderId,
      title:
          "Invitation Status ${originalNotification.title.toUpperCase()} Group",
      message:
          '${fromUser.userName} has ${accepted ? 'accepted' : 'denied'} your invitation to join the group',
      timestamp: DateTime.now(),
      category: Category.groupUpdate,
    );

    // Save the new notification
    final ntfCreated = await notificationManagement.notificationService
        .createNotification(ntOwner); // returns ID

    // Add the ID to the admin's list
    final admin = await userManagement.userService
        .getUserById(originalNotification.senderId);

    admin.notifications?.add(ntfCreated.id);
    await userManagement.userService.updateUser(admin);
  }
}
