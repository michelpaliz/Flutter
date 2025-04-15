//Abstrac class should not contain logic

import '../../../../a-models/user_model/user.dart';

abstract class AuthRepository {
  User? get currentUser;
  set currentUser(User? user); // optional setter, depending on your needs

  Future<User?> logIn({required String email, required String password});
  Future<String> createUser({
    required String userName,
    required String name,
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> initialize();
  Future<User?> getCurrentUserModel();
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  );
}
