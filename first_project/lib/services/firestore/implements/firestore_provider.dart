import 'dart:async';
import 'dart:developer' as devtools show log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/models/group.dart';

import 'package:first_project/services/auth/auth_exceptions.dart';
import 'package:first_project/services/firestore/firestore_exceptions.dart';
import 'package:first_project/services/user/user_provider.dart';
import '../../../models/event.dart';
import '../../../models/notification_user.dart';
import '../../../models/user.dart';
import '../../../utilities/sharedprefs.dart';
import '../Ifirestore_provider.dart';

/**Calling the uploadPersonToFirestore function, you can await the returned future and handle the success or failure messages accordingly: */
class FireStoreProvider implements StoreProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /** Here I update the user and also if he is in groups  */
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

        //We update the user in his groups
        if (user.groupIds.isNotEmpty) {
          updateUserInGroups(user);
        }

        return 'User has been updated';
      }

      return 'User not found';
    } catch (error) {
      throw Exception('Error updating user in Firestore: $error');
    }
  }

  @override
  Future<void> updateEvent(Event event) async {
    try {
      User? currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw UserNotFoundAuthException();
      }

      String userId = currentUser.id;

      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');

      DocumentReference userRef = userCollection.doc(userId);

      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;

        List<dynamic>? events = userData['events'];

        if (events != null) {
          // Find the event with the matching ID
          int eventIndex = events.indexWhere((e) => e['id'] == event.id);

          if (eventIndex != -1) {
            // Update the event object in the list
            events[eventIndex] = event.toMap();

            // Update the events field in the user document
            await userRef.update({'events': events});

            return;
          } else {
            throw EventNotFoundException();
          }
        } else {
          throw EventNotFoundException();
        }
      } else {
        throw UserNotFoundException();
      }
    } catch (error) {
      throw Exception('Error updating event in Firestore: $error');
    }
  }

/** the removeEvent method fetches the user's document from Firestore, removes the event from the updatedEvents list, and then updates the events field in the Firestore document with the updated event list. */
  @override
  Future<List<Event>> removeEvent(String eventId) async {
    User? user = await SharedPrefsUtils.getUserFromPreferences();

    if (user != null) {
      List<Event> updatedEvents = user.events;
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
  Future<void> addNotification(User user, NotificationUser notification) async {
    try {
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');

      DocumentReference userRef =
          userCollection.doc(user.id); // Use the user's ID directly

      // Update the user's notifications field
      await userRef.update({
        '_notifications': FieldValue.arrayUnion([notification.toJson()])
      });

      print('Notification added successfully');

      //We update the user in his groups
      updateUserInGroups(user);
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  @override
  Future<void> addGroup(Group group) async {
    final groupData = {
      'id': group.id,
      'groupName': group.groupName,
      'ownerId': group.ownerId,
      'userRoles': group.userRoles,
      'calendar': group.calendar?.toJson(), // Serialize Calendar to JSON
      'users': group.users
          .map((user) => user.toJson())
          .toList(), // Serialize each user to JSON
    };

    await _firestore.collection('groups').doc(group.id).set(groupData);
  }

  @override
  Future<void> updateGroup(Group group) async {
    final groupData = {
      'groupName': group.groupName,
      'ownerId': group.ownerId,
      'userRoles': group.userRoles,
      'calendar': group.calendar?.toJson(), // Serialize Calendar to JSON
      'users': group.users
          .map((user) => user.toJson())
          .toList(), // Serialize each user to JSON
    };

    // Get a reference to the document you want to update
    final groupReference = _firestore.collection('groups').doc(group.id);

    // Update the document with the new data
    await groupReference.update(groupData);
  }

  @override
  Future<Group?> getGroupFromId(String groupId) async {
    try {
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      if (groupSnapshot.exists) {
        return Group.fromJson(groupSnapshot.data()! as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching group: $e');
      return null;
    }
  }

  @override
  Future<void> updateUserInGroups(User user) async {
    // Iterate through the user's group IDs and update each group's user list
    for (String groupId in user.groupIds) {
      Group? group = await getGroupFromId(
          groupId); // Replace with your logic to fetch the group
      if (group != null) {
        int userIndex = group.users.indexWhere((u) => u.id == user.id);
        if (userIndex != -1) {
          group.users[userIndex] = user;
          await updateGroup(
              group); // Replace with your logic to update the group
        }
      }
    }
  }
  
  @override
  Future<void> addUserToGroup(User user, NotificationUser notificationUser) async {
    // We update first the groupsId that the user has joined
      user.groupIds.add(notificationUser.id);
    //Here I update the user in firestore
      await updateUser(user);
    //Here I update the group in firestore because this user will be added.
    Group groupFetched; 
    groupFetched = (await getGroupFromId(notificationUser.id))!;
    groupFetched.users.add(user);
    await updateGroup(groupFetched);
  }
  
@override
Future<User?> getUserById(String userId) async {
  try {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      // Parse the data from the snapshot
      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;
      return User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        events: userData['events'],
        groupIds: userData['groupIds'],
        notifications: userData['notifications'],
        photoUrl: userData['photoUrl']
      );
    } else {
      // User not found
      return null;
    }
  } catch (error) {
    print('Error fetching user: $error');
    return null;
  }
}


  
}
