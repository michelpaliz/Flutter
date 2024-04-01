import '../../../models/event.dart';
import '../../../models/group.dart';
import '../../../models/notification_user.dart';
import '../../../models/user.dart';

abstract class FirestoreRepository {
  Future<List<Event>> removeEvent(String eventId);
  Future<String> updateUser(User user);
  Future<void> updateEvent(Event event);
  Future<void> addNotification(User user, NotificationUser notification);
  Future<void> addGroup(Group group);
  Future<void> updateGroup(Group group);
  Future<Group?> getGroupFromId(String groupId);
  Future<void> updateUserInGroups(User user);
  Future<void> addUserToGroup(User user, NotificationUser notification);
  Future<User?> getUserById(String userId);
  Future<List<Group>> fetchUserGroups(List<String>? groupIds);
  Future<void> deleteGroup(String groupId);
  Future<User?> getUserByName(String userName);
  Future<void> removeUserInGroup(User user, Group group);
  Future<User> getOwnerFromGroup(Group group);
  Future<Event?> getEventFromGroupById(String eventId, String groupId);
  Future<Event?> getEventFromUserById(User user, String eventId);
  Future<User?> getUserByUserName(String userName);
  Future<void> changeUsername(String newUserName);
  Future<void> sendNotificationToUsers(Group group, User admin);

}
