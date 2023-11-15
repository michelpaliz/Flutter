import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/auth_repository.dart';
import 'package:first_project/services/auth/auth_user.dart';
import 'package:first_project/services/auth/implements/auth_provider.dart';

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
  Future<User?> generateUserCustomeModel() =>
      repository.generateUserCustomeModel();

  @override
  User? get costumeUser => repository.costumeUser;

  @override
  set costumeUser(User? user) {
    if (user != null) {
      repository.costumeUser = user;
    }
  }
}
