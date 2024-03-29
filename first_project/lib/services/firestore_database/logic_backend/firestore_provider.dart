import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/services/auth/exceptions/auth_exceptions.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/services/auth/logic_backend/auth_service.dart';
import 'package:first_project/services/firestore_database/exceptions/firestore_exceptions.dart';
import 'package:first_project/services/user/user_provider.dart';
import '../../../models/event.dart';
import '../../../models/notification_user.dart';
import '../../../models/user.dart';
import 'firestore_repository.dart';

/**Calling the uploadPersonToFirestore function, you can await the returned future and handle the success or failure messages accordingly: */
class FirestoreProvider implements FirestoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final ProviderManagement? _providerManagement;

  FirestoreProvider({
    ProviderManagement? providerManagement,
  })  : _authService = AuthService.firebase(),
        _providerManagement = providerManagement;

  // ** HANDLE EVENT DATA ***

  Future<void> updateEvent(Event event) async {
    try {
      if (event.groupId != null && event.groupId!.isNotEmpty) {
        // Retrieve the group object based on event.groupId
        Group? group = await getGroupFromId(event.groupId!);

        // Update the event data in the group's calendar
        // You can access the group's calendar using group.calendar
        // Update the event within the calendar as needed

        // Example: Update event in the calendar's events list
        int eventIndex =
            group!.calendar.events.indexWhere((e) => e.id == event.id);
        if (eventIndex != -1) {
          group.calendar.events[eventIndex] = event;
        }

        // Save the updated group object back to Firestore
        CollectionReference groupsCollection =
            FirebaseFirestore.instance.collection('groups');
        await groupsCollection.doc(group.id).update(group.toJson());
      } else {
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
      }
    } catch (error) {
      throw Exception('Error updating event in Firestore: $error');
    }
  }

/** the removeEvent method fetches the user's document from Firestore, removes the event from the updatedEvents list, and then updates the events field in the Firestore document with the updated event list. */
  @override
  Future<List<Event>> removeEvent(String eventId) async {
    // User? user = await SharedPrefsUtils.getUserFromPreferences();
    User? user = _authService.costumeUser;

    if (user != null) {
      List<Event> updatedEvents = user.events;
      updatedEvents.removeWhere((event) => event.id == eventId);

      user.events = updatedEvents;

      // await SharedPrefsUtils.storeUser(user);
      _authService.costumeUser = user;

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

  // ** HANDLE NOTIFICATIONS DATA **

  @override
  Future<void> addNotification(User user, NotificationUser notification) async {
    try {
      CollectionReference userCollection =
          FirebaseFirestore.instance.collection('users');

      DocumentReference userRef =
          userCollection.doc(user.id); // Use the user's ID directly

      // Update the user's notifications field
      await userRef.update({
        'notifications': FieldValue.arrayUnion([notification.toJson()])
      });

      print('Notification added successfully');

      //We update the user in his groups
      updateUserInGroups(user);
    } catch (e) {
      print('Error adding notification: $e');
    }
  }

  Future<void> _createNotificationsForGroups(
      Group group, User currentUser) async {
    // Create notification details
    final notificationTitle =
        '${currentUser.name.toUpperCase()} invited you to a group';
    final notificationMessage =
        '${currentUser.name.toUpperCase()} invited you to this Group: ${group.groupName}';
    final notificationQuestion = 'Would you like to join this group ?';

    for (User user in group.users) {
      if (user.id != currentUser.id) {
        final notification = NotificationUser(
          id: group.id,
          ownerId: currentUser.id,
          title: notificationTitle,
          message: notificationMessage,
          timestamp: DateTime.now(),
          hasQuestion: true,
          question: notificationQuestion,
          isAnswered: false,
        );

        user.notifications.add(notification);
        user.hasNewNotifications = true;
        await updateUser(user);
      }
    }
  }

  // ** HANDLE GROUP DATA  **

  @override
  Future<void> addGroup(Group group) async {
    try {
      // Serialize the group object to JSON
      final groupData = group.toJson();

      // Create the group document in the 'groups' collection
      await _firestore.collection('groups').doc(group.id).set(groupData);

      //Now we are gonna create a new URL reference for the group's image and update it
      // _updatePhotoURLForGroup(group);

      // Update the current user's group IDs
      final currentUser = AuthService.firebase().costumeUser;
      currentUser!.groupIds.add(group.id);
      await updateUser(currentUser);
      _providerManagement?.updateUser(currentUser);
      _providerManagement?.addGroup(group);

      // Create notifications for group members
      await _createNotificationsForGroups(group, currentUser);
    } catch (e) {
      print('Error adding group: $e');
      throw 'Failed to add the group';
    }
  }

  @override
  Future<void> updateGroup(Group group) async {
    final groupData = group.toJson(); // Serialize the entire Group object

    // Get a reference to the document you want to update
    final groupReference = _firestore.collection('groups').doc(group.id);

    // Update the document with the new data
    try {
      await groupReference.update(groupData);
      // Now we are gonna create a new URL reference for the group's image and update it
      // _updatePhotoURLForGroup(group);
      _providerManagement?.updateGroup(group);
      // We now update the user's groups ids in case the user a new user has been added
      for (var user in group.users) {
        // Get the first user which is the new user
        var updatedUser = group.users.firstWhere((u) => u.id == user.id);
        updateUser(updatedUser);
      }
    } catch (e) {
      print("Error updating group: $e");
      // Handle the error appropriately, e.g., show a snackbar or alert to the user.
    }
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

  /**
   * @param user
   * @return This function ensures that whenever a user's information is updated, the changes are reflected in all groups they belong to, ensuring consistency across the application.
   */
  @override
  Future<void> updateUserInGroups(User user) async {
    // Iterate through the user's group IDs and update each group's user list
    for (String groupId in user.groupIds.toList()) {
      // Retrieve the group object corresponding to the groupId
      Group? group = await getGroupFromId(groupId);

      // Check if the group is found
      if (group != null) {
        // Find the index of the user within the group's users list
        int userIndex = group.users.indexWhere((u) => u.id == user.id);

        // If the user is found within the group
        if (userIndex != -1) {
          // Create a copy of the group's users list
          List<User> updatedUsers = List.from(group.users);

          // Update the user data within the group's users list
          updatedUsers[userIndex] = user;

          // Replace the group's users list with the updated list
          group.users = updatedUsers;

          // Update the group with the modified user list
          await updateGroup(
              group); // Replace with your logic to update the group
        }
      }
    }
  }

  /**Adds the user to the group introduced and it adds the groupId of the group in the user's groupsID */
  @override
  Future<void> addUserToGroup(
      User user, NotificationUser notificationUser) async {
    // Check if the group ID already exists in the user's groupIds list
    if (!user.groupIds.contains(notificationUser.id)) {
      // The group ID is not already in the list, so we add it
      user.groupIds.add(notificationUser.id);

      // Update the user in Firestore
      await updateUser(user);
    }

    // Fetch the group
    Group groupFetched = (await getGroupFromId(notificationUser.id))!;

    // Check if the user is not already in the group (based on their ID)
    if (!groupFetched.users.any((groupUser) => groupUser.id == user.id)) {
      // The user is not in the group, so we add them
      groupFetched.users.add(user);

      // Perform any additional logic to update the group role for the new user

      // Update the group in Firestore
      await updateGroup(groupFetched);
    }
  }

  @override
  Future<List<Group>> fetchUserGroups(List<String>? groupIds) async {
    List<Group> groups = [];

    if (groupIds != null) {
      for (String groupId in groupIds) {
        Group? group = await getGroupFromId(groupId);
        if (group != null) {
          groups.add(group);
        }
      }
    }

    return groups;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      //Fetch the list of groups from the database
      CollectionReference groupEventCollections =
          FirebaseFirestore.instance.collection('groups');

      // Fetch the list of users from the group
      DocumentSnapshot groupSnapshot =
          await groupEventCollections.doc(groupId).get();

      //The id of the users
      List<String> groupUserIds = [];

      //This is the list of users
      List<dynamic> usersList = groupSnapshot['users'];

      for (var userObj in usersList) {
        String userId = userObj['id'];
        groupUserIds.add(userId);
      }

      //Update the user's groups Id in the database
      for (String userId in groupUserIds) {
        User? user = await getUserById(userId);
        if (user != null) {
          user.groupIds.remove(groupId);
          await updateUser(user);
        }
      }

      // Delete the group's events collection
      await groupEventCollections.doc(groupId).collection('events').get().then(
        (snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        },
      );

      Group? groupFetched = await getGroupFromId(groupId);
      _providerManagement?.removeGroupById(groupFetched!);

      // Delete the group document
      await groupEventCollections.doc(groupId).delete();
    } catch (error) {
      // Handle the error
      print("Error deleting group: $error");
    }

    //We proceed to delete the events of the deleted group in the users collection
  }

  /// Overrides the method to remove a user from a group in Firestore.
  ///
  /// This method removes the specified [user] from the [group] by updating both
  /// the user and the group documents in Firestore.
  ///
  /// Parameters:
  /// - [user]: The user to be removed from the group.
  /// - [group]: The group from which the user will be removed.
  ///
  /// Returns:
  /// - A `Future<void>` representing the asynchronous operation.
  ///
  /// Throws:
  /// - An error if any error occurs during the removal process.
  @override
  Future<void> removeUserInGroup(User user, Group group) async {
    try {
      // Remove the user from the group's list
      List<User> updatedUsers =
          group.users.where((u) => u.name != user.name).toList();
      group.users = updatedUsers;

      // Remove the group ID from the user's data
      user.groupIds.remove(group.id);

      // Remove the user from the user roles list in the group
      group.userRoles.remove(user.id);

      // Update both the user and the group in Firestore
      await updateUser(user);
      await updateGroup(group);
    } catch (error) {
      print('Error removing user from group: $error');
    }
  }

  @override
  Future<User> getOwnerFromGroup(Group group) async {
    try {
      // 1. Query Firestore to retrieve the owner's user document.
      DocumentSnapshot userDocSnapshot = await _firestore
          .collection(
              'users') // Assuming 'users' is the collection name for users
          .doc(group
              .ownerId) // Replace with the actual path to the owner's user document
          .get();

      // 2. Convert Firestore document data to JSON format.
      Map<String, dynamic> userData =
          userDocSnapshot.data() as Map<String, dynamic>;

      // 3. Create a User object using the user.fromJson method.
      User owner = User.fromJson(
          userData); // Replace with your actual JSON parsing logic

      return owner;
    } catch (e) {
      // Handle any errors that may occur during the process.
      print("Error retrieving owner: $e");
      rethrow; // Rethrow the error for higher-level handling if needed.
    }
  }

  @override
  Future<Event?> getEventFromGroupById(String eventId, String groupId) async {
    try {
      Group? fetchedGroup = await getGroupFromId(groupId);

      if (fetchedGroup != null) {
        Event? foundEvent = fetchedGroup.calendar.events.firstWhere(
          (event) => event.id == eventId,
        );

        return foundEvent;
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
    return null;
  }

  // ** HANDLE USER DATA ***

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

        User? currentUser = _authService.costumeUser;

        if (currentUser!.id == user.id) {
          _authService.costumeUser = user;

          // Update the user in his groups
          if (user.groupIds.isNotEmpty) {
            updateUserInGroups(user);
          }
        }

        // Use _providerManagement here
        _providerManagement?.updateUser(user);

        return 'User has been updated';
      }

      return 'User not found';
    } catch (error) {
      throw Exception('Error updating user in Firestore: $error');
    }
  }

  @override
  Future<User?> getUserById(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        // Parse the data from the snapshot
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        return User.fromJson(userData); // Use the fromJson factory method
      } else {
        // User not found
        return null;
      }
    } catch (error) {
      print('Error fetching user: $error');
      return null;
    }
  }

  @override
  Future<User?> getUserByName(String userName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userName', isEqualTo: userName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming you want to return the first user found with the given username
        DocumentSnapshot userSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> userData =
            userSnapshot.data() as Map<String, dynamic>;
        return User.fromJson(userData);
      } else {
        // User not found
        return null;
      }
    } catch (error) {
      print('Error fetching user by name: $error');
      return null;
    }
  }

  @override
  Future<Event?> getEventFromUserById(User user, String eventId) async {
    try {
      // First, you should fetch the user's list of events.
      List<Event> userEvents =
          user.events; // Assuming User has a list of events.

      // Find the event you're looking for based on the provided eventIdToRetrieve.
      Event? event = userEvents.firstWhere(
        (event) =>
            event.id ==
            eventId, // Provide a default value if the event is not found.
      );

      return event;
    } catch (e) {
      print("Error while getting event: $e");
      return null;
    }
  }

  Future<User?> getUserByUserName(String userName) async {
    try {
      // 1. Query Firestore to retrieve the user document with the matching username.
      QuerySnapshot userQuerySnapshot = await _firestore
          .collection('users')
          .where('userName', isEqualTo: userName)
          .get();

      // 2. Check if a user with the given username exists.
      if (userQuerySnapshot.docs.isNotEmpty) {
        // 3. Get the first document (assuming usernames are unique) and convert it to JSON format.
        Map<String, dynamic> userData =
            userQuerySnapshot.docs.first.data() as Map<String, dynamic>;

        // 4. Create a User object using the `fromJson` method.
        User user =
            User.fromJson(userData); // Replace with your JSON parsing logic

        return user;
      } else {
        // User with the provided username was not found.
        return null;
      }
    } catch (e) {
      // Handle any errors that may occur during the process.
      print("Error retrieving user: $e");
      rethrow; // Rethrow the error for higher-level handling if needed.
    }
  }

  @override
  Future<void> changeUsername(String newUserName) async {
    try {
      // Get the current user
      final user = _authService.costumeUser;

      if (user != null) {
        // Check if the new username is already taken
        bool isUsernameTaken = await _isUsernameAlreadyTaken(newUserName);

        if (isUsernameTaken) {
          // Handle the case where the username is already taken
          // You can throw an exception, log the error, or handle it as needed
          print('Error: Username is already taken. Choose a different one.');
          throw UsernameAlreadyTakenException();
        }

        // Update the userName field in Firestore
        await _firestore.collection('users').doc(user.id).update({
          'userName': newUserName,
        });

        // Optionally, update any other fields in your custom user object
        user.userName = newUserName;

        // Save the updated user object to your AuthService or wherever it is managed
        _authService.costumeUser = user;

        _providerManagement!.updateUser(user);
      }
    } catch (error) {
      // Handle errors, you may want to log or rethrow the error
      print("Error changing user name: $error");
      throw error;
    }
  }

// Function to check if a username is already taken
  Future<bool> _isUsernameAlreadyTaken(String username) async {
    try {
      // Query Firestore to check if the username exists in the 'users' collection
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('userName', isEqualTo: username)
          .get();

      // If the querySnapshot is not empty, the username is already taken
      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      // Handle errors, log or rethrow the error as needed
      print("Error checking if username is already taken: $error");
      throw error;
    }
  }
}
