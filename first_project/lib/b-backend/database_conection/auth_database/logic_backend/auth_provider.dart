import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show AuthCredential, EmailAuthProvider, FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/b-backend/database_conection/auth_database/exceptions/auth_exceptions.dart';
import 'package:first_project/b-backend/database_conection/auth_database/exceptions/password_exceptions.dart';
import 'package:first_project/b-backend/database_conection/auth_database/logic_backend/auth_user.dart';
import 'package:first_project/b-backend/database_conection/node_services/user_services.dart';

import 'package:flutter/material.dart';

import '../../../../firebase_options.dart';
import '../../../../a-models/user.dart';
import 'auth_repository.dart';

class AuthProvider extends ChangeNotifier implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final StreamController<User?> _authStateController =
      StreamController<User?>();

  User? _currentUser;

  AuthProvider() {
    _initializeAuthStateListener();
  }

  void _initializeAuthStateListener() {
    _firebaseAuth.authStateChanges().listen((user) async {
      _currentUser = user != null
          ? await _userService.getUserByEmail(user.email.toString())
          : null;
      _authStateController.add(_currentUser);
      notifyListeners();
    });
  }

  Stream<User?> get authStateStream => _authStateController.stream;

  @override
  AuthUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? AuthUser.fromFirebase(user) : null;
  }

  @override
  User? get costumeUser => _currentUser;

  set costumeUser(User? userUpdated) {
    if (userUpdated != null) {
      _currentUser = userUpdated;
      notifyListeners();
    }
  }

  Future<String> createUser({
    required String userName,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: user.uid);
        User person = User(
          id: user.uid,
          authID: user.uid,
          name: name,
          userName: userName,
          email: user.email!,
          photoUrl: '',
          groupIds: [],
          events: [],
          notifications: [],
        );
        _currentUser = await _userService.createUser(person);
        return 'User created successfully';
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') throw WeakPasswordException();
      if (e.code == 'email-already-in-use')
        throw EmailAlreadyUseAuthException();
      if (e.code == 'invalid-email') throw InvalidEmailAuthException();
      throw GenericAuthException();
    }
  }

  Future<String> uploadPersonToFirestore({
    required User person,
    required String documentId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(documentId)
          .set(person.toJson());
      return 'User with ID $documentId has been added';
    } catch (error) {
      throw 'There was an error adding the person to Firestore: $error';
    }
  }

  String generateCustomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(
        10, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = currentUser;
      if (user != null) return user;
      throw UserNotLoggedInAuthException();
    } on FirebaseAuthException catch (user) {
      if (user.code == 'user-not-found') throw UserNotFoundAuthException();
      if (user.code == 'wrong-password') throw WrongPasswordAuthException();
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await _firebaseAuth.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Future<User?> generateUserCustomModel() async {
    final userFetched = _firebaseAuth.currentUser;
    if (userFetched != null) {
      try {
        _currentUser = await _userService.getUserByAuthID(userFetched.uid);
        return _currentUser;
      } catch (error) {
        throw Exception('Error retrieving user data from Firestore: $error');
      }
    }
    return null;
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) throw UserNotSignedInException();

    try {
      final credential = EmailAuthProvider.credential(
          email: currentUser.email!, password: currentPassword);
      await currentUser.reauthenticateWithCredential(credential);

      if (newPassword != confirmPassword) throw PasswordMismatchException();
      await currentUser.updatePassword(newPassword);
    } on FirebaseAuthException {
      throw CurrentPasswordMismatchException();
    }
  }
}
