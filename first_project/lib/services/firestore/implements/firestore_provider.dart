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

  @override
  Stream<List<Event>> getEventsStream(User user) {
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // Query the users collection based on the user's email
    Query query = usersCollection.where('email', isEqualTo: user.email);

    // Create a stream transformer to map the query snapshots to event lists
    StreamTransformer<QuerySnapshot, List<Event>> transformer =
        StreamTransformer.fromHandlers(handleData: (snapshot, sink) {
      List<Event> events = [];
      if (snapshot.docs.isNotEmpty) {
        // Get the first document from the snapshot
        DocumentSnapshot userDoc = snapshot.docs.first;

        // Retrieve the events and groupId fields from the user document
        List<dynamic> eventIds = userDoc.get('events');
        String groupId = userDoc.get('groupId');

        // Query the events collection using the retrieved eventIds
        CollectionReference eventsCollection =
            FirebaseFirestore.instance.collection('events');
        Query eventsQuery =
            eventsCollection.where(FieldPath.documentId, whereIn: eventIds);

        eventsQuery.get().then((eventsSnapshot) {
          eventsSnapshot.docs.forEach((eventDoc) {
            // Create an Event object directly from the event document data
            Event event = Event(
              id: eventDoc.id,
              // Populate other properties based on your document structure
              startDate: eventDoc['startDate'].toDate(),
              endDate: eventDoc['endDate'].toDate(),
              note: eventDoc['note'],
              groupId: groupId,
            );
            events.add(event);
          });

          sink.add(events);
        });
      } else {
        sink.add(events);
      }
    });

    // Return the transformed stream
    return query.snapshots().transform(transformer);
  }
}
