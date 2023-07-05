import 'dart:async';
import 'dart:developer' as devtools show log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/models/user.dart';

import '../../../models/event.dart';
import '../../../utiliies/sharedprefs.dart';
import '../Ifirestore_provider.dart';

/**Calling the uploadPersonToFirestore function, you can await the returned future and handle the success or failure messages accordingly: */
class FireStoreProvider implements StoreProvider {
  @override
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

  @override
  Future<String> updateUser(User user) async {
    try {
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');

      QuerySnapshot userQuerySnapshot = await userCollection
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentReference userRef = userQuerySnapshot.docs.first.reference;

        await userRef.update(user.toJson()); // Update the user document

        return 'User has been updated';
      }

      return 'User not found';
    } catch (error) {
      throw Exception('Error updating user in Firestore: $error');
    }
  }

/** the removeEvent method fetches the user's document from Firestore, removes the event from the updatedEvents list, and then updates the events field in the Firestore document with the updated event list. */
  @override
  Future<List<Event>> removeEvent(String eventId) async {
    User? user = await SharedPrefsUtils.getUserFromPreferences();

    if (user != null) {
      List<Event> updatedEvents = user.events ?? [];
      updatedEvents.removeWhere((event) => event.id == eventId);

      user.events = updatedEvents;

      await SharedPrefsUtils.storeUser(user);

      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');

      QuerySnapshot userQuerySnapshot = await userCollection
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        DocumentReference userRef = userQuerySnapshot.docs.first.reference;

        await userRef.update({
          'events': updatedEvents.map((event) => event.toMap()).toList(),
        });
      }

      return updatedEvents; // Return the updated event list
    }

    return []; // Return an empty list if no update was performed
  }


}
