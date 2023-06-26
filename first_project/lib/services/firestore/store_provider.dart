import '../../models/user.dart';

abstract class StoreProvider {
  Future<String> uploadPersonToFirestore({required User person});
}
