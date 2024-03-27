import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/services/firestore_database/logic_backend/firestore_service.dart';

class AppServices {
  final ProviderManagement providerManagement;
  final FirestoreService storeService;

  AppServices(this.providerManagement, this.storeService);
}
