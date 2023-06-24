import '../../models/person.dart';

abstract class StoreProvider {
  Future<String> uploadPersonToFirestore({required Person person});
}
