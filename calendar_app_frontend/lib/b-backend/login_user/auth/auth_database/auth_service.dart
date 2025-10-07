import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/login_user/auth/auth_database/auth_repository.dart';
import 'package:flutter/foundation.dart';

class AuthService with ChangeNotifier implements AuthRepository {
  final AuthRepository repository;

  AuthService(this.repository);

  User? _currentUser;
  Future<void>? _initFuture;

  // --- Public accessor required by AuthRepository ---
  @override
  User? get currentUser => _currentUser;

  // Keep the setter to satisfy the interface, but route through _setUser so we notify properly.
  @override
  set currentUser(User? user) => _setUser(user);

  // Helper to compare Users (customize as needed)
  bool _sameUser(User? a, User? b) {
    // If your User overrides ==, just do: return a == b;
    // Otherwise compare key fields:
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    return a.id == b.id && a.email == b.email; // add more fields if needed
  }

  void _setUser(User? next) {
    if (!_sameUser(_currentUser, next)) {
      _currentUser = next;
      notifyListeners();
    }
  }

  // --- Initialization: idempotent & cached ---
  @override
  Future<void> initialize() {
    return _initFuture ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    // Ask repo to initialize (load token, try session restore, etc.)
    await repository.initialize();

    // Pull initial user from repo (if it populated one)
    _setUser(repository.currentUser);
  }

  // --- Auth actions: update state & notify ---
  @override
  Future<User?> logIn({required String email, required String password}) async {
    final user = await repository.logIn(email: email, password: password);
    _setUser(user); // triggers AuthGate to swap to Home
    return _currentUser;
  }

  @override
  Future<void> logOut() async {
    await repository.logOut();
    _setUser(null); // triggers AuthGate to show Login
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
  ) =>
      repository.changePassword(currentPassword, newPassword, confirmPassword);

  @override
  Future<String?> getToken() => repository.getToken();
}
