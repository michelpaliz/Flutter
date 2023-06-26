
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:first_project/models/event.dart';
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

Future<void> updateUserInFirestore(User user) async {
  // Update the user object with the event added to their list of events
  List<Event>? eventList;
  user.events = eventList;
  user.groupId = null;

  // Store the updated user object
  await SharedPrefsUtils.storeUser(user);

  // Get the user collection reference in Firestore
  CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  // Query the user collection for the document with a specific condition (e.g., matching user email)
  QuerySnapshot userQuerySnapshot = await userCollection
      .where('email', isEqualTo: user.email)
      .limit(1)
      .get();

  if (userQuerySnapshot.docs.isNotEmpty) {
    // Get the document reference of the first matching document
    DocumentReference userRef = userQuerySnapshot.docs.first.reference;

    // Update the user document with the event added to their list of events
    await userRef.update({
      'events': eventList!.map((event) => event.toMap()).toList(),
      'groupId': null,
    });

    // Display a success message
    // scaffoldKey.currentState?.showSnackBar(
    //   SnackBar(content: Text('User updated successfully!')),
    // );
  }
}