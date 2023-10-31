//Abstrac class should not contain logic
import 'package:first_project/services/auth/auth_user.dart';

import '../../models/user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  User? get costumeUser;
  set costumeUser(User? user);
  Future<AuthUser> logIn({required String email, required String password});
  Future<String> createUser(
      {required String userName, required String name, required String email, required String password});
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<User?> generateUserCustomeModel();

}
