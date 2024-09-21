//Abstrac class should not contain logic

import 'package:first_project/b-backend/database_conection/auth_database/logic_backend/auth_user.dart';

import '../../../../a-models/user.dart';

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
