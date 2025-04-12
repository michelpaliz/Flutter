import 'package:first_project/a-models/model/user_data/user.dart';
import 'package:first_project/b-backend/auth/auth_database/auth/auth_service.dart';

class LoginInitializer {
  final AuthService authService;
  // final FirestoreService storeService;
  User? userFetched;

  LoginInitializer({
    required this.authService,
    // required this.storeService,
  }) : userFetched = null;

  Future<void> initializeUserAndServices(String email, String password) async {
    await authService.logIn(email: email, password: password);
    final user = authService.currentUser;
    bool emailVerified = user?.isEmailVerified ?? false;

    if (emailVerified) {
      User? customUser = await authService.generateUserCustomModel();
      authService.customUser = customUser;
      userFetched = authService.customUser;
    }
  }

  get getUser => userFetched;
}
