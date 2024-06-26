//Abstrac class should not contain logic
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_user.dart';

import '../../../../models/user.dart';

abstract class AuthRepository {
  Future<void> initialize();
  AuthUser? get currentUser;
  User? get costumeUser;
  set costumeUser(User? user);
  Future<AuthUser> logIn({required String email, required String password});
  Future<String> createUser(
      {required String userName,
      required String name,
      required String email,
      required String password});
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<User?> generateUserCustomModel();
  Future<void> changePassword(
      String currentPassword, String newPassword, String confirmPassword);
}
