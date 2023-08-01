import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/services/auth/auth_exceptions.dart';
import 'package:first_project/services/auth/auth_user.dart';

import '../../../firebase_options.dart';
import '../../../models/user.dart';
import '../../firestore/implements/firestore_service.dart';
import '../auth_provider.dart';

class FirebaseAuthProvider implements AuthProvider {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Private variable to store the current user
  User? _currentUser;
  @override
  Future<String> createUser({
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
          user.uid,
          name,
          user.email!,
          null,
          groupIds: null,
        );

        // Upload the user object to Firestore using the UID as the document ID
        return await StoreService.firebase().uploadPersonToFirestore(
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
Future<User?> getCurrentUserAsCustomeModel() async {
  final firebaseUser = _firebaseAuth.currentUser;
  if (firebaseUser != null) {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).get();
    if (userSnapshot.exists) {
      return User.fromJson(userSnapshot.data() as Map<String, dynamic>); // Explicit cast to Map<String, dynamic>
    }
  }
  return null;
}

  @override
  User? get costumeUser {
    // Use the stored _currentUser if available,
    // otherwise, return null
    return _currentUser;
  }

}
