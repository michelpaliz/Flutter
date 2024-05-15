import '../../../../models/event.dart';
import '../../../../models/group.dart';
import '../../../../models/notification_user.dart';
import '../../../../models/user.dart';

abstract class FirestoreRepository {
  Future<void> addGroup(Group group);
  Future<void> addNotification(User user, NotificationUser notification);
  Future<void> addUserToGroup(User user, NotificationUser notification);
  Future<void> changeUsername(String newUserName);
  Future<String> updateUser(User user);
  Future<void> deleteGroup(String groupId);
  Future<List<Group>> fetchUserGroups(List<String>? groupIds);
  Future<Event?> getEventFromGroupById(String eventId, String groupId);
  Future<Event?> getEventFromUserById(User user, String eventId);
  Future<Group?> getGroupFromId(String groupId);
  Future<User?> getUserById(String userId);
  Future<User?> getUserByName(String userName);
  Future<User?> getUserByUserName(String userName);
  Future<User> getOwnerFromGroup(Group group);
  Future<List<Event>> removeEvent(String eventId);
  Future<void> removeUserInGroup(User user, Group group);
  Future<void> sendNotificationToUsers(Group group, User admin);
  Future<void> leavingNotificationForGroup(Group group);
  Future<void> updateEvent(Event event);
  Future<void> updateGroup(Group group);
  Future<void> updateUserInGroups(User user);
}
