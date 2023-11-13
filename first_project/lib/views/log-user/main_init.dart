import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/views/provider/provider_management.dart';

class MainInitializer {
  final ProviderManagement providerManagement;
  final StoreService storeService;

  MainInitializer({
    required this.providerManagement,
    required this.storeService,
  });

  Future<void> initializeUserGroup(User user) async {
    // Fetch additional data or perform any other necessary initialization
    List<Group>? fetchedGroups = await storeService.fetchUserGroups(providerManagement.user!.groupIds);
    providerManagement.setGroups = fetchedGroups;
  }
}
