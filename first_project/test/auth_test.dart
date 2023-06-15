import 'package:first_project/services/auth/auth_exceptions.dart';
import 'package:first_project/services/auth/auth_provider.dart';
import 'package:first_project/services/auth/auth_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Mock Authetication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with',
        () => expect(provider.isInitialized, false));

    test('Cannot log out if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NoInitializedException>()));
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after init', () {
      expect(provider.currentUser, null);
    });

    test('Should be able to init in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.initialize(), true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = provider.createUser(
          email: "michaelpaliz@hotmail.com", password: '123456');
      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPassword = provider.createUser(
          email: 'michelpaliz@hotmail.com', password: '1234567');
      expect(badPassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await provider.createUser(email: 'foo', password: 'bar');
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logOut();
      await provider.logIn(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NoInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NoInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NoInitializedException();
    if (email == 'michelpaliz@hotmail.com') throw UserNotFoundAuthException();
    if (password == '123456') throw WrongPasswordAuthException();
    const user = AuthUser(false);
    _user = user;
    return Future(() => user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NoInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NoInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(true);
    _user = newUser;
  }
}
