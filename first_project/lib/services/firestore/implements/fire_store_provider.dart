import 'dart:async';

import 'package:first_project/models/person.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../store_provider.dart';

/**Calling the uploadPersonToFirestore function, you can await the returned future and handle the success or failure messages accordingly: */
class FireStoreProvider implements StoreProvider {
  @override
  Future<String> uploadPersonToFirestore({required Person person}) {
    Completer<String> completer = Completer<String>();
    FirebaseFirestore.instance
        .collection('people')
        .add(person.toMap())
        .then((value) {
      completer.complete('User has been added');
    }).catchError((error) {
      completer.completeError(
          "There was an error adding the person to the firestore  $error");
    });
    return completer.future;
  }
}
