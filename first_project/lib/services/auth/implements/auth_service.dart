import 'package:first_project/models/user.dart';
import 'package:first_project/views/service_provider/provider_management.dart';
import 'package:first_project/services/auth/auth_repository.dart';
import 'package:first_project/services/auth/auth_user.dart';
import 'package:first_project/services/auth/implements/auth_provider.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';

class AuthService implements AuthRepository {
final AuthRepository provider;

  const AuthService._(this.provider);

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
      provider.createUser(
        userName: userName,
        email: email,
        password: password,
        name: name,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) =>
      provider.logIn(
        email: email,
        password: password,
      );

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();

  @override
  Future<void> initialize() => provider.initialize();

  @override
  Future<User?> generateUserCustomeModel() =>
      provider.generateUserCustomeModel();

  @override
  User? get costumeUser => provider.costumeUser;

  @override
  set costumeUser(User? user) {
    if (user != null) {
      provider.costumeUser = user;
    }
  }
}
