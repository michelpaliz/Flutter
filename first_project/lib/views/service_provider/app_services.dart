import 'package:first_project/views/service_provider/provider_management.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';

class AppServices {
  final ProviderManagement providerManagement;
  final StoreService storeService;

  AppServices(this.providerManagement, this.storeService);
}