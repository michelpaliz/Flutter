import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/views/provider/provider_management.dart';

class LoginInitializer {
  final AuthService authService;
  final ProviderManagement providerManagement;
  final StoreService storeService;

  LoginInitializer({
    required this.authService,
    required this.providerManagement,
    required this.storeService,
  });

  Future<void> initializeUserAndServices(String email, String password) async {
    await authService.logIn(email: email, password: password);
    final user = authService.currentUser;
    bool emailVerified = user?.isEmailVerified ?? false;

    if (emailVerified) {
      User? customUser = await authService.generateUserCustomeModel();

      authService.costumeUser = customUser;

      List<Group>? fetchedGroups =
          await storeService.fetchUserGroups(customUser?.groupIds);

      providerManagement.setGroups = fetchedGroups;
    }
  }
}
