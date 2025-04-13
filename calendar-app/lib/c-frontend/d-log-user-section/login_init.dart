import 'package:first_project/a-models/user_model/user.dart';

import '../../b-backend/auth/auth_database/auth/auth_provider.dart';

class LoginInitializer {
  final AuthProvider authProvider;
  User? _user;

  LoginInitializer({required this.authProvider});

  /// Attempts login and sets up user model (no email verification required)
  Future<void> initializeUserAndServices(String email, String password) async {
    // Attempt login
    await authProvider.logIn(email: email, password: password);

    // Generate and store user model
    final user = await authProvider.getCurrentUserModel();

    if (user != null) {
      authProvider.currentUser = user;
      _user = user;
    } else {
      throw Exception("Failed to load user data.");
    }
  }

  /// Getter for the fetched user
  User? get user => _user;
}
