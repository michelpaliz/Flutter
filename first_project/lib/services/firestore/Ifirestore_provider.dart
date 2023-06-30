import '../../models/event.dart';
import '../../models/user.dart';

abstract class StoreProvider {
  Future<String> uploadPersonToFirestore({required User person});
  Future<List<Event>> removeEvent(String eventId);
  Future<String> updateUser(User user);
}
