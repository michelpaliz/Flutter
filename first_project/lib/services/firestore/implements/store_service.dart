import 'package:first_project/models/user.dart';
import 'package:first_project/services/firestore/implements/fire_store_provider.dart';

import '../store_provider.dart';

class StoreService extends StoreProvider {
  
  final StoreProvider provider;

  StoreService(this.provider);

  factory StoreService.firebase() => StoreService(FireStoreProvider());

  @override
  Future<String> uploadPersonToFirestore({required User person}) =>
      provider.uploadPersonToFirestore(person: person);
}
