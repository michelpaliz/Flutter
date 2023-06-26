
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:first_project/utiliies/sharedprefs.dart';

import '../models/user.dart' as app_user;
import '../models/user.dart';

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

class UserUtils {
  // ...

  static Future<void> updateUser(User user) async {
    // Update the user object in shared preferences
    await SharedPrefsUtils.storeUser(user);

    // Get the user document reference in Firestore
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user.email);

    // Update the user document with the new data
    await userRef.update({
      'events': user.events?.map((event) => event.toMap()).toList(),
      'groupId': user.groupId,
    });
  }

  // ...
}

