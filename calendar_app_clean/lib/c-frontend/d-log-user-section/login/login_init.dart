import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/d-stateManagement/user_management.dart';

class LoginInitializer {
  final AuthProvider authProvider;
  final UserManagement userManagement;

  User? _user;

  LoginInitializer({
    required this.authProvider,
    required this.userManagement,
  });

  /// Attempts login and sets up user model (no email verification required)
  Future<void> initializeUserAndServices(String email, String password) async {
    // Attempt login
    await authProvider.logIn(email: email, password: password);

    // Get the user model from the provider
    final user = await authProvider.getCurrentUserModel();

    if (user != null) {
      authProvider.currentUser = user;
      _user = user;

      // 👇 Sync user with UserManagement directly
      userManagement.setCurrentUser(user);
    } else {
      throw Exception("Failed to load user data.");
    }
  }

  /// Getter for the fetched user (if needed elsewhere)
  User? get user => _user;
}
