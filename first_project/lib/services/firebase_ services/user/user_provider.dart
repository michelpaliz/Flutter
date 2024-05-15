
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../models/user.dart' as app_user;

app_user.User? currentUser;

Future<app_user.User?> getCurrentUser() async {
  if (currentUser == null) {
    firebase_auth.User? firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    return firebaseUser != null ? app_user.User.fromFirebaseUser(firebaseUser) : null;
  }
  return currentUser;
}

// ...

Future<app_user.User?> main() async {
  // Initialize Firebase

  app_user.User? user = await getCurrentUser();
  return user;
  // Rest of your code
}