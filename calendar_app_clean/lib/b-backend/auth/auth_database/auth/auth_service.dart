import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/b-backend/auth/auth_database/auth/auth_repository.dart';

class AuthService implements AuthRepository {
  final AuthRepository repository;

  AuthService(this.repository); // 👈 No singleton, no factory

  @override
  Future<String> createUser({
    required String userName,
    required String name,
    required String email,
    required String password,
  }) =>
      repository.createUser(
        userName: userName,
        email: email,
        password: password,
        name: name,
      );

  @override
  User? get currentUser => repository.currentUser;

  @override
  set currentUser(User? user) {
    repository.currentUser = user;
  }

  @override
  Future<User?> logIn({
    required String email,
    required String password,
  }) async {
    return await repository.logIn(email: email, password: password);
  }

  @override
  Future<void> logOut() async {
    await repository.logOut();
  }

  @override
  Future<void> sendEmailVerification() => repository.sendEmailVerification();

  @override
  Future<void> initialize() => repository.initialize();

  @override
  Future<User?> getCurrentUserModel() => repository.getCurrentUserModel();

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) =>
      repository.changePassword(currentPassword, newPassword, confirmPassword);
}
