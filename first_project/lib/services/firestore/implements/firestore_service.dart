import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/auth_management.dart';
import 'package:first_project/services/firestore/implements/firestore_provider.dart';

import '../../../models/event.dart';
import '../Ifirestore_provider.dart';

class StoreService extends StoreProvider {
  final StoreProvider provider;

  // Private constructor for the Singleton pattern
  StoreService._(this.provider);

  // Static field to hold the single instance of StoreService
  static StoreService? _instance;

  // Factory method to get the single instance of StoreService
factory StoreService.firebase(ProviderManagement providerManagement) {
    if (_instance == null) {
      _instance = StoreService._(FireStoreProvider(providerManagement: providerManagement));
    }
    return _instance!;
  }
  
  /**when you call removeEvent on an instance of StoreService, it will delegate the call to the underlying FireStoreProvider and execute its removeEvent method. */
  @override
  Future<List<Event>> removeEvent(String eventId) =>
      provider.removeEvent(eventId);

  @override
  Future<String> updateUser(User user) => provider.updateUser(user);

  @override
  Future<void> updateEvent(Event event) => provider.updateEvent(event);

  @override
  Future<void> addNotification(User user, NotificationUser notification) =>
      provider.addNotification(user, notification);

  @override
  Future<void> addGroup(Group group) => provider.addGroup(group);

  @override
  Future<void> updateGroup(Group group) => provider.updateGroup(group);

  @override
  Future<Group?> getGroupFromId(String groupId) =>
      provider.getGroupFromId(groupId);

  @override
  Future<void> updateUserInGroups(User user) =>
      provider.updateUserInGroups(user);

  @override
  Future<void> addUserToGroup(User user, NotificationUser notification) =>
      provider.addUserToGroup(user, notification);

  @override
  Future<User?> getUserById(String userId) => provider.getUserById(userId);

  @override
  Future<List<Group>> fetchUserGroups(List<String>? groupIds) =>
      provider.fetchUserGroups(groupIds);

  @override
  Future<void> deleteGroup(String groupId) => provider.deleteGroup(groupId);

  @override
  Future<User?> getUserByName(String userName) =>
      provider.getUserByName(userName);

  @override
  Future<void> removeAll(User user, Group group) =>
      provider.removeAll(user, group);

  @override
  Future<User> getOwnerFromGroup(Group group) =>
      provider.getOwnerFromGroup(group);

  @override
  Future<Event?> getEventFromGroupById(String eventId, String groupId) =>
      provider.getEventFromGroupById(eventId, groupId);

  @override
  Future<Event?> getEventFromUserById(User user, String eventId) =>
      provider.getEventFromUserById(user, eventId);

  @override
  Future<User?> getUserByUserName(String userName) => provider.getUserByUserName(userName);
}