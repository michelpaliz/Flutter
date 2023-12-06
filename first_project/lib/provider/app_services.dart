import 'package:first_project/provider/provider_management.dart';
import 'package:first_project/services/firestore_database/implements/firestore_service.dart';

class AppServices {
  final ProviderManagement providerManagement;
  final FirestoreService storeService;

  AppServices(this.providerManagement, this.storeService);
}
