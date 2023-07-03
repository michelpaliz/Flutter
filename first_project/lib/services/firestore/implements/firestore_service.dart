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
  Stream<List<Event>> getEventsStream(User user) =>
      provider.getEventsStream(user);
}
