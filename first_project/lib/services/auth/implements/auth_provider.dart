import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/services/auth/auth_exceptions.dart';
import 'package:first_project/services/auth/auth_management.dart';
import 'package:first_project/services/auth/auth_user.dart';
import 'package:flutter/material.dart';

import '../../../firebase_options.dart';
import '../../../models/user.dart';
import '../../firestore/implements/firestore_service.dart';
import '../auth_repository.dart';

class AuthProvider implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Private variable to store the current user
  User? _currentUser;
  // final StoreService storeService;

  AuthProvider() {
    // Initialize the authentication state listener
    _initializeAuthStateListener();
  }
//Function added to user the provider package
  void _initializeAuthStateListener() {
    _firebaseAuth.authStateChanges().listen((user) async {
      // Fetch and update the custom user model based on the user's email
      final updatedUser = (user != null)
          ? await _getUserDataFromFirestore(user.email.toString())
          : null;

      if (_currentUser != updatedUser) {
        _currentUser = updatedUser; // Notify listeners when the user changes
      }
    });
  }

  // Add a StreamController for the authentication state
  final StreamController<User?> _authStateController =
      StreamController<User?>();

  // Define a getter to access the authentication state stream
  Stream<User?> get authStateStream => _authStateController.stream;

  @override
  Future<String> createUser({
    required String userName,
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Set the custom ID as the user's display name in Firebase Auth
        await user.updateProfile(displayName: user.uid);

        // Create a User object using the UID as the user ID
        User person = User(
            id: user.uid,
            name: name,
            userName: userName,
            email: user.email!,
            photoUrl: '',
            groupIds: [],
            events: [],
            notifications: []);

        // Upload the user object to Firestore using the UID as the document ID
        return await uploadPersonToFirestore(
          person: person,
          documentId: user.uid,
        );
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'firebase_auth/email-already-in-use') {
        throw EmailAlreadyUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
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
    String chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    String id = '';

    for (int i = 0; i < 10; i++) {
      int randomIndex = random.nextInt(chars.length);
      id += chars[randomIndex];
    }

    return id;
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (user) {
      if (user.code == 'user-not-found') {
        // devtools.log('User not found');
        throw UserNotFoundAuthException();
      } else if (user.code == 'wrong-password') {
        // devtools.log('Wrong password');
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<User?> generateUserCustomeModel() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (userSnapshot.exists) {
        _currentUser =
            User.fromJson(userSnapshot.data() as Map<String, dynamic>);
        return _currentUser; // Return the populated user object
      }
    }
    throw Exception(
        "User data not found"); // Throw an exception when the user doesn't exist
  }

// Fetch user data from Firestore based on the provided email
  Future<User?> _getUserDataFromFirestore(String userEmail) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get(); // Use get() to fetch the data as a query result

      if (userSnapshot.docs.isNotEmpty) {
        final userData = userSnapshot.docs.first.data();
        // Update _currentUser with the new data
        _currentUser = User.fromJson(userData);
      }

      return _currentUser;
    } catch (e) {
      print("Error fetching user data from Firestore: $e");
      return null;
    }
  }

  @override
  User? get costumeUser {
    return _currentUser;
  }

  set costumeUser(User? userUpdated) {
    if (userUpdated != null) {
      _currentUser = userUpdated;
    }
  }
}
