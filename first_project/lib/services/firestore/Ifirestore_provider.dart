import '../../models/event.dart';
import '../../models/user.dart';

abstract class StoreProvider {
  Future<String> uploadPersonToFirestore(
      {required User person, required String documentId});
  Future<List<Event>> removeEvent(String eventId);
  Future<String> updateUser(User user);
  Future<void> updateEvent(Event event);
}
