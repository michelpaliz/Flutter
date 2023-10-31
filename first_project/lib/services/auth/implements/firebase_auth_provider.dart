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

  // Add a StreamController for the authentication state
  final StreamController<User?> _authStateController =
      StreamController<User?>();

  // Define a getter to access the authentication state stream
  Stream<User?> get authStateStream => _authStateController.stream;

  FirebaseAuthProvider() {
    // Initialize the authentication state listener
    initializeAuthStateListener();
  }

  void initializeAuthStateListener() {
    // Listen to authentication state changes and add them to the stream
    _firebaseAuth.authStateChanges().listen((user) async {
      // Fetch and update the custom user model based on the user's email
      final updatedUser = (user != null)
          ? await _getUserDataFromFirestore(user.email.toString())
          : null;

      // Only update the _currentUser if it's different from the previous one
      if (_currentUser != updatedUser) {
        _currentUser = updatedUser;
        _authStateController.add(_currentUser);
      }
    });
  }

  // Remember to dispose of the stream controller when it's no longer needed
  void dispose() {
    _authStateController.close();
  }

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

// Fetch user data from Firestore based on the provided userId
// Fetch user data from Firestore based on the provided email
  Future<User?> _getUserDataFromFirestore(String userEmail) async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail) // Query by email
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // In this example, we assume that email is unique, so we use the first document found.
        final userData = userSnapshot.docs.first.data();
        return User.fromJson(userData);
      }

      return null; // Return null when the user doesn't exist in Firestore
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
