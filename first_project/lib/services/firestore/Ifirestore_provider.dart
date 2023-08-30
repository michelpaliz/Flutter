import '../../models/event.dart';
import '../../models/group.dart';
import '../../models/notification_user.dart';
import '../../models/user.dart';

abstract class StoreProvider {
  Future<String> uploadPersonToFirestore(
      {required User person, required String documentId});
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
  Future<void> removeAll(User user, Group group);
}
