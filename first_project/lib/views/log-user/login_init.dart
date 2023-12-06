import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore_database/implements/firestore_service.dart';

class LoginInitializer {
  final AuthService authService;
  final FirestoreService storeService;
  User? userFetched;

  LoginInitializer({
    required this.authService,
    required this.storeService,
  }) : userFetched = null;

  Future<void> initializeUserAndServices(String email, String password) async {
    await authService.logIn(email: email, password: password);
    final user = authService.currentUser;
    bool emailVerified = user?.isEmailVerified ?? false;

    if (emailVerified) {
      User? customUser = await authService.generateUserCustomModel();
      authService.costumeUser = customUser;
      userFetched = authService.costumeUser;
    }
  }

  get getUser => userFetched;
}
