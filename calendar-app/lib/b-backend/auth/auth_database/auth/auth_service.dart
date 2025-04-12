import 'package:first_project/a-models/model/user_data/user.dart';
import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/b-backend/auth/auth_database/auth/auth_repository.dart';

class AuthService implements AuthRepository {
  final AuthRepository repository;

  const AuthService._(this.repository);

  static AuthService? _instance;

  factory AuthService.custom() {
    _instance ??= AuthService._(AuthProvider());
    return _instance!;
  }

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
  }) =>
      repository.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => repository.logOut();

  @override
  Future<void> sendEmailVerification() => repository.sendEmailVerification();

  @override
  Future<void> initialize() => repository.initialize();

  @override
  Future<User?> generateUserCustomModel() =>
      repository.generateUserCustomModel();

  @override
  Future<void> changePassword(
          String currentPassword, String newPassword, String confirmPassword) =>
      repository.changePassword(currentPassword, newPassword, confirmPassword);
}
