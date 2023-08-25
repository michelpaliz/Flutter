import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/firestore/implements/firestore_provider.dart';

import '../../../models/event.dart';
import '../Ifirestore_provider.dart';

class StoreService extends StoreProvider {
  final StoreProvider provider;

  StoreService(this.provider);

  factory StoreService.firebase() => StoreService(FireStoreProvider());

  @override
  Future<String> uploadPersonToFirestore(
          {required User person, required String documentId}) =>
      provider.uploadPersonToFirestore(person: person, documentId: documentId);

  /**when you call removeEvent on an instance of StoreService, it will delegate the call to the underlying FireStoreProvider and execute its removeEvent method. */
  @override
  Future<List<Event>> removeEvent(String eventId) =>
      provider.removeEvent(eventId);

  @override
  Future<String> updateUser(User user) => provider.updateUser(user);

  @override
  Future<void> updateEvent(Event event) => provider.updateEvent(event);

  @override
  Future<void> addNotification(User user, NotificationUser notification) => provider.addNotification(user, notification);

  @override
  Future<void> addGroup(Group group) => provider.addGroup(group);
  
  @override
  Future<void> updateGroup(Group group) => provider.updateGroup(group);
  
  @override
  Future<void> getGroupFromId(String groupId) => provider.getGroupFromId(groupId);
  
  @override
  Future<void> updateUserInGroups(User user) => provider.updateUserInGroups(user);
  
  @override
  Future<void> addUserToGroup(User user, NotificationUser notification) => provider.addUserToGroup(user,notification);

  
}
