import 'package:flutter/foundation.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/b-backend/api/auth/auth_database/auth_repository.dart';

class AuthService with ChangeNotifier implements AuthRepository {
  final AuthRepository repository;

  AuthService(this.repository);

  User? _currentUser;
  Future<void>? _initFuture;

  @override
  User? get currentUser => _currentUser;

  @override
  set currentUser(User? user) => _setUser(user);

  void _setUser(User? next) {
    if (_currentUser != next) { // uses User.== we added
      _currentUser = next;
      notifyListeners();
    }
  }

  @override
  Future<void> initialize() {
    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    // Let errors bubble so AuthGate can show an error UI
    await repository.initialize();
    _setUser(repository.currentUser);
  }

  @override
  Future<User?> logIn({required String email, required String password}) async {
    final user = await repository.logIn(email: email, password: password);
    _setUser(user);
    return _currentUser;
  }

  @override
  Future<void> logOut() async {
    await repository.logOut();
    _setUser(null);
  }

  @override
  Future<String> createUser({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.createUser(name: name, email: email, password: password);
  }

  @override
  Future<void> sendEmailVerification() => repository.sendEmailVerification();

  @override
  Future<User?> getCurrentUserModel() => repository.getCurrentUserModel();

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) => repository.changePassword(currentPassword, newPassword, confirmPassword);
}