import 'package:first_project/models/user.dart';
import 'package:first_project/backend/firebase_%20services/auth/logic_backend/auth_provider.dart';
import 'package:first_project/backend/firebase_%20services/auth/logic_backend/auth_repository.dart';
import 'package:first_project/backend/firebase_%20services/auth/logic_backend/auth_user.dart';

class AuthService implements AuthRepository {
  final AuthRepository repository;

  const AuthService._(this.repository);

  static AuthService? _instance; // Singleton instance

  factory AuthService.firebase() {
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
  AuthUser? get currentUser => repository.currentUser;

  @override
  Future<AuthUser> logIn({
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
  User? get costumeUser => repository.costumeUser;

  @override
  set costumeUser(User? user) {
    if (user != null) {
      repository.costumeUser = user;
    }
  }

  @override
  Future<void> changePassword(
          String currentPassword, String newPassword, String confirmPassword) =>
      repository.changePassword(currentPassword, newPassword, confirmPassword);

}
