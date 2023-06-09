import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/auth_provider.dart';
import 'package:first_project/services/auth/auth_user.dart';
import 'package:first_project/services/auth/implements/firebase_auth_provider.dart';

//WE FUSE ALL THE SERVERS
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthService implements AuthProvider {
  final AuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  static firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  @override
  Future<String> createUser({
    required String name,
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
        name: '',
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

  static String? getCurrentUserId() {
    final firebase_auth.User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return firebaseUser.uid;
    }
    return null;
  }
}
  // 