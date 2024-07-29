import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';

import '../../../../models/event.dart';
import 'firestore_repository.dart';

class FirestoreService extends FirestoreRepository {
  final FirestoreRepository repository;

  // Private constructor for the Singleton pattern
  FirestoreService._(this.repository);

  // Static field to hold the single instance of StoreService
  static FirestoreService? _instance;

  // Factory method to get the single instance of StoreService
  // factory FirestoreService.firebase(ProviderManagement? providerManagement) {
  //   if (_instance == null) {
  //     _instance = FirestoreService._(
  //         FirestoreProvider(providerManagement: providerManagement));
  //   }
  //   return _instance!;
  // }

  /**when you call removeEvent on an instance of StoreService, it will delegate the call to the underlying FireStoreProvider and execute its removeEvent method. */
  @override
  Future<List<Event>> removeEvent(String eventId) =>
      repository.removeEvent(eventId);

  @override
  Future<String> updateUser(User user) => repository.updateUser(user);

  @override
  Future<void> updateEvent(Event event) => repository.updateEvent(event);

  @override
  Future<void> addNotification(User user, NotificationUser notification) =>
      repository.addNotification(user, notification);

  @override
  Future<void> addGroup(Group group) => repository.addGroup(group);

  @override
  Future<void> updateGroup(Group group) => repository.updateGroup(group);

  @override
  Future<Group?> getGroupFromId(String groupId) =>
      repository.getGroupFromId(groupId);

  @override
  Future<void> updateUserInGroups(User user) =>
      repository.updateUserInGroups(user);

  @override
  Future<void> addUserToGroup(User user, NotificationUser notification) =>
      repository.addUserToGroup(user, notification);

  @override
  Future<User?> getUserById(String userId) => repository.getUserById(userId);

  @override
  Future<List<Group>> fetchUserGroups(List<String>? groupIds) =>
      repository.fetchUserGroups(groupIds);

  @override
  Future<void> deleteGroup(String groupId) => repository.deleteGroup(groupId);

  @override
  Future<User?> getUserByName(String userName) =>
      repository.getUserByName(userName);

  @override
  Future<void> removeUserInGroup(User user, Group group) =>
      repository.removeUserInGroup(user, group);

  @override
  Future<User> getOwnerFromGroup(Group group) =>
      repository.getOwnerFromGroup(group);

  @override
  Future<Event?> getEventFromGroupById(String eventId, String groupId) =>
      repository.getEventFromGroupById(eventId, groupId);

  @override
  Future<Event?> getEventFromUserById(User user, String eventId) =>
      repository.getEventFromUserById(user, eventId);

  @override
  Future<User?> getUserByUserName(String userName) =>
      repository.getUserByUserName(userName);

  @override
  Future<void> changeUsername(String newUserName) =>
      repository.changeUsername(newUserName);

  @override
  Future<void> sendNotificationToUsers(Group group, User admin) =>
      repository.sendNotificationToUsers(group, admin);

  @override
  Future<void> leavingNotificationForGroup(Group group) =>
      repository.leavingNotificationForGroup(group);
}
