// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:first_project/models/group.dart';
// import 'package:first_project/services/firebase_%20services/auth/exceptions/auth_exceptions.dart';
// import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
// import 'package:first_project/services/firebase_%20services/firestore_database/exceptions/firestore_exceptions.dart';
// import 'package:first_project/services/firebase_%20services/user/user_provider.dart';
// import 'package:first_project/stateManangement/provider_management.dart';

// import '../../../../models/event.dart';
// import '../../../../models/notification_user.dart';
// import '../../../../models/user.dart';
// import 'firestore_repository.dart';

// /**Calling the uploadPersonToFirestore function, you can await the returned future and handle the success or failure messages accordingly: */
// class FirestoreProvider implements FirestoreRepository {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthService _authService;
//   final ProviderManagement? _providerManagement;

//   FirestoreProvider({
//     ProviderManagement? providerManagement,
//   })  : _authService = AuthService.firebase(),
//         _providerManagement = providerManagement;

//   // ** HANDLE EVENT DATA ***

//   Future<void> updateEvent(Event event) async {
//     try {
//       if (event.groupId != null && event.groupId!.isNotEmpty) {
//         // Retrieve the group object based on event.groupId
//         Group? group = await getGroupFromId(event.groupId!);

//         // Update the event data in the group's calendar
//         // You can access the group's calendar using group.calendar
//         // Update the event within the calendar as needed

//         // Example: Update event in the calendar's events list
//         int eventIndex =
//             group!.calendar.events.indexWhere((e) => e.id == event.id);
//         if (eventIndex != -1) {
//           group.calendar.events[eventIndex] = event;
//         }

//         // Save the updated group object back to Firestore
//         CollectionReference groupsCollection =
//             FirebaseFirestore.instance.collection('groups');
//         await groupsCollection.doc(group.id).update(group.toJson());
//       } else {
//         User? currentUser = await getCurrentUser();
//         if (currentUser == null) {
//           throw UserNotFoundAuthException();
//         }

//         String userId = currentUser.id;

//         CollectionReference userCollection =
//             FirebaseFirestore.instance.collection('users');

//         DocumentReference userRef = userCollection.doc(userId);

//         DocumentSnapshot userSnapshot = await userRef.get();

//         if (userSnapshot.exists) {
//           Map<String, dynamic> userData =
//               userSnapshot.data() as Map<String, dynamic>;

//           List<dynamic>? events = userData['events'];

//           if (events != null) {
//             // Find the event with the matching ID
//             int eventIndex = events.indexWhere((e) => e['id'] == event.id);

//             if (eventIndex != -1) {
//               // Update the event object in the list
//               events[eventIndex] = event.toMap();

//               // Update the events field in the user document
//               await userRef.update({'events': events});

//               return;
//             } else {
//               throw EventNotFoundException();
//             }
//           } else {
//             throw EventNotFoundException();
//           }
//         } else {
//           throw UserNotFoundException();
//         }
//       }
//     } catch (error) {
//       throw Exception('Error updating event in Firestore: $error');
//     }
//   }

// /** the removeEvent method fetches the user's document from Firestore, removes the event from the updatedEvents list, and then updates the events field in the Firestore document with the updated event list. */
//   @override
//   Future<List<Event>> removeEvent(String eventId) async {
//     // User? user = await SharedPrefsUtils.getUserFromPreferences();
//     User? user = _authService.costumeUser;

//     if (user != null) {
//       List<Event> updatedEvents = user.events;
//       updatedEvents.removeWhere((event) => event.id == eventId);

//       user.events = updatedEvents;

//       // await SharedPrefsUtils.storeUser(user);
//       _authService.costumeUser = user;

//       CollectionReference userCollection =
//           FirebaseFirestore.instance.collection('users');

//       QuerySnapshot userQuerySnapshot = await userCollection
//           .where('email', isEqualTo: user.email)
//           .limit(1)
//           .get();

//       if (userQuerySnapshot.docs.isNotEmpty) {
//         DocumentReference userRef = userQuerySnapshot.docs.first.reference;

//         await userRef.update({
//           'events': updatedEvents.map((event) => event.toMap()).toList(),
//         });
//       }

//       return updatedEvents; // Return the updated event list
//     }

//     return []; // Return an empty list if no update was performed
//   }

//   // ** HANDLE NOTIFICATIONS DATA **

//   @override
//   Future<void> addNotification(User user, NotificationUser notification) async {
//     try {
//       CollectionReference userCollection =
//           FirebaseFirestore.instance.collection('users');

//       DocumentReference userRef =
//           userCollection.doc(user.id); // Use the user's ID directly

//       // Update the user's notifications field
//       await userRef.update({
//         'notifications': FieldValue.arrayUnion([notification.toJson()])
//       });

//       _providerManagement!.addNotification(notification);
//       print('Notification added successfully');

//       //We update the user in his groups
//       updateUserInGroups(user);
//     } catch (e) {
//       print('Error adding notification: $e');
//     }
//   }

//   // ** HANDLE GROUP DATA  **

//   @override
//   Future<void> addGroup(Group group) async {
//     try {
//       // Serialize the group object to JSON
//       final groupData = group.toJson();

//       // Create the group document in the 'groups' collection
//       await _firestore.collection('groups').doc(group.id).set(groupData);

//       //Now we are gonna create a new URL reference for the group's image and update it
//       // _updatePhotoURLForGroup(group);

//       // Update the current user's group IDs
//       User? currentUser = await getCurrentUser();
//       currentUser!.groupIds.add(group.id);
//       await updateUser(currentUser);
//       _providerManagement?.updateUser(currentUser);
//       _providerManagement?.addGroup(group);

//       // Create notifications for group members
//       await sendNotificationToUsers(group, currentUser);
//     } catch (e) {
//       print('Error adding group: $e');
//       throw 'Failed to add the group';
//     }
//   }

//   /// Sends notifications to users when they are invited to join a group.
//   /// This function creates and sends notifications to users based on the group
//   /// invitation. It sends a congratulatory notification to the group administrator
//   /// and an invitation notification to each user invited to join the group.
//   ///
//   /// Parameters:
//   ///   - group: The group for which notifications are being sent.
//   ///   - admin: The user who created the group and is the administrator.
//   ///
//   /// This function performs the following steps:
//   /// 1. Checks if the admin is an Administrator based on their role in the group.
//   /// 2. If the admin is an Administrator, creates a congratulatory notification
//   ///    for the administrator.
//   /// 3. Adds the congratulatory notification to the administrator's notification list.
//   /// 4. Updates the administrator's document in Firestore with the new notification.
//   /// 5. Iterates through each user ID in the invitedUsers map of the group.
//   /// 6. Retrieves user details from Firestore based on the user ID.
//   /// 7. Creates an invitation notification for each user.
//   /// 8. Adds the invitation notification to the user's notification list.
//   /// 9. Updates the user's document in Firestore with the new notification.
//   ///
//   /// Note: This function assumes that the group and user data are available in Firestore.
//   /// It also assumes that the Firestore service methods for retrieving and updating
//   /// documents are implemented elsewhere in the codebase.
//   Future<void> sendNotificationToUsers(Group group, User admin) async {
//     // Check if the admin is an Administrator based on invitedUsers
//     bool isAdmin = group.userRoles.containsKey(admin.userName) &&
//         group.userRoles[admin.userName] == 'Administrator';

//     // Create congratulatory notification for the Administrator
//     if (isAdmin) {
//       final congratulatoryTitle = 'Congratulations!';
//       final congratulatoryMessage = 'You created the group: ${group.groupName}';
//       final congratulatoryNotification = NotificationUser(
//         id: group.id,
//         ownerId: admin.id,
//         title: congratulatoryTitle,
//         message: congratulatoryMessage,
//         timestamp: DateTime.now(),
//         hasQuestion: false,
//         question: '',
//       );

//       // Add congratulatory notification to the Administrator's notification list
//       admin.notifications.add(congratulatoryNotification);
//       _providerManagement!.addNotification(congratulatoryNotification);
//       admin.hasNewNotifications = true;

//       // Update Administrator's document in Firestore
//       await updateUser(admin);
//     }

//     // Loop through each user ID in the invitedUsers map
//     for (final userName in group.invitedUsers!.keys) {
//       // Get the user details
//       User? user = await getUserByUserName(userName);

//       // Create invitation notification for the user
//       final userNotificationTitle = 'Join ${group.groupName}';
//       final userNotificationMessage =
//           'You have been invited to join the group: ${group.groupName}';
//       final userNotificationQuestion = 'Would you like to join this group ?';

//       // Create notification for the user
//       final userNotification = NotificationUser(
//         id: group.id,
//         ownerId: admin.id,
//         title: userNotificationTitle,
//         message: userNotificationMessage,
//         timestamp: DateTime.now(),
//         hasQuestion: true,
//         question: userNotificationQuestion,
//       );

//       // Add notification to the user's list
//       user!.notifications.add(userNotification);
//       user.hasNewNotifications = true;

//       // Update user document in Firestore
//       await updateUser(user);
//     }
//   }

//   /** We check if the current user is an administrator by verifying their role in the group.
//   If the user is an administrator, we create a notification indicating that the group has been removed by them.
//   If the user is not an administrator, we create a notification indicating that they have left the group.
//   We then create notifications for each member of the group, excluding invited users if the current user is not an administrator and the group is not being removed by an administrator.*/
//   @override
//   Future<void> leavingNotificationForGroup(Group group) async {
//     // Check if the current user is an Administrator
//     User? currentUser = await getCurrentUser();
//     bool isAdmin = group.userRoles.containsKey(currentUser!.userName) &&
//         group.userRoles[currentUser.userName] == 'Administrator';

//     // Create a notification for the Administrator
//     if (isAdmin) {
//       final notificationTitle = 'Group Removed';
//       final message = 'You removed the group ${group.groupName}';
//       final notificationContent = NotificationUser(
//         id: group.id,
//         ownerId: group.ownerId,
//         title: notificationTitle,
//         message: message,
//         timestamp: DateTime.now(),
//         hasQuestion: false,
//         question: '',
//       );

//       // Add the notification to the Administrator's list
//       currentUser.notifications.add(notificationContent);
//       _providerManagement!.addNotification(notificationContent);
//       currentUser.hasNewNotifications = true;

//       // Update the Administrator's document in Firestore
//       await updateUser(currentUser);
//     } else {
//       // Create a notification for the user who is leaving the group
//       final leavingNotificationTitle = 'You Left the Group';
//       final leavingNotificationMessage =
//           'You left the group ${group.groupName}';
//       final leavingNotification = NotificationUser(
//         id: group.id,
//         ownerId: group.ownerId,
//         title: leavingNotificationTitle,
//         message: leavingNotificationMessage,
//         timestamp: DateTime.now(),
//         hasQuestion: false,
//         question: '',
//       );

//       // Add the notification to the user's list
//       currentUser.notifications.add(leavingNotification);
//       _providerManagement!.addNotification(leavingNotification);
//       currentUser.hasNewNotifications = true;

//       // Update the user's document in Firestore
//       await updateUser(currentUser);
//     }

//     // Create a notification for the members
//     final memberNotificationTitle =
//         isAdmin ? 'Group Removed' : 'Member Left the Group';
//     final memberNotificationMessage = isAdmin
//         ? 'The group ${group.groupName} has been removed by the administrator'
//         : '${currentUser.userName} has left the group';

//     // Loop through each user in the group's members list
//     for (final member in group.users) {
//       // Exclude invited users if the current user is not an administrator and the group is not being removed by an administrator
//       if (!isAdmin && group.invitedUsers!.containsKey(member.userName)) {
//         continue;
//       }

//       // Create the notification for the member
//       final memberNotification = NotificationUser(
//         id: group.id,
//         ownerId: group.ownerId,
//         title: memberNotificationTitle,
//         message: memberNotificationMessage,
//         timestamp: DateTime.now(),
//         hasQuestion: false,
//         question: '',
//       );

//       // Add the notification to the member's list
//       member.notifications.add(memberNotification);
//       member.hasNewNotifications = true;

//       // Update the member's document in Firestore
//       await updateUser(member);
//     }
//   }

//   @override
//   Future<void> updateGroup(Group group) async {
//     final groupData = group.toJson(); // Serialize the entire Group object

//     // Get a reference to the document you want to update
//     final groupReference = _firestore.collection('groups').doc(group.id);

//     // Update the document with the new data
//     try {
//       await groupReference.update(groupData);
//       // Now we are gonna create a new URL reference for the group's image and update it
//       // _updatePhotoURLForGroup(group);
//       _providerManagement?.updateGroup(group);
//       // _providerManagement?.setGroups;
//       // We now update the user's groups ids in case the user a new user has been added
//       for (var user in group.users) {
//         // Get the first user which is the new user
//         var updatedUser = group.users.firstWhere((u) => u.id == user.id);
//         updateUser(updatedUser);
//       }
//     } catch (e) {
//       print("Error updating group: $e");
//       // Handle the error appropriately, e.g., show a snackbar or alert to the user.
//     }
//   }

//   @override
//   Future<Group?> getGroupFromId(String groupId) async {
//     try {
//       DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
//           .collection('groups')
//           .doc(groupId)
//           .get();

//       if (groupSnapshot.exists) {
//         return Group.fromJson(groupSnapshot.data()! as Map<String, dynamic>);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       print('Error fetching group: $e');
//       return null;
//     }
//   }

//   /**
//    * @param user
//    * @return This function ensures that whenever a user's information is updated, the changes are reflected in all groups they belong to, ensuring consistency across the application.
//    */
//   @override
//   Future<void> updateUserInGroups(User user) async {
//     // Iterate through the user's group IDs and update each group's user list
//     for (String groupId in user.groupIds.toList()) {
//       // Retrieve the group object corresponding to the groupId
//       Group? group = await getGroupFromId(groupId);

//       // Check if the group is found
//       if (group != null) {
//         // Find the index of the user within the group's users list
//         int userIndex = group.users.indexWhere((u) => u.id == user.id);

//         // If the user is found within the group
//         if (userIndex != -1) {
//           // Create a copy of the group's users list
//           List<User> updatedUsers = List.from(group.users);

//           // Update the user data within the group's users list
//           updatedUsers[userIndex] = user;

//           // Replace the group's users list with the updated list
//           group.users = updatedUsers;

//           // Update the group with the modified user list
//           await updateGroup(
//               group); // Replace with your logic to update the group
//         }
//       }
//     }
//   }

//   /**Adds the user to the group introduced and it adds the groupId of the group in the user's groupsID */
//   @override
//   Future<void> addUserToGroup(
//       User user, NotificationUser notificationUser) async {
//     // Check if the group ID already exists in the user's groupIds list
//     if (!user.groupIds.contains(notificationUser.id)) {
//       // The group ID is not already in the list, so we add it
//       user.groupIds.add(notificationUser.id);
//       // Update the user in Firestore
//       await updateUser(user);
//     }

//     // Fetch the group
//     Group groupFetched = (await getGroupFromId(notificationUser.id))!;

//     // Check if the user is not already in the group (based on their ID)
//     if (!groupFetched.users.any((groupUser) => groupUser.id == user.id)) {
//       // The user is not in the group, so we add them
//       groupFetched.users.add(user);

//       // Perform any additional logic to update the group role for the new user

//       // Update the group in Firestore
//       await updateGroup(groupFetched);
//     }
//   }

//   @override
//   Future<List<Group>> fetchUserGroups(List<String>? groupIds) async {
//     List<Group> groups = [];

//     if (groupIds != null) {
//       // Use Future.wait to fetch all groups concurrently
//       List<Future<Group?>> futures =
//           groupIds.map((groupId) => getGroupFromId(groupId)).toList();
//       List<Group?> results = await Future.wait(futures);

//       // Filter out any null results
//       groups = results
//           .where((group) => group != null)
//           .map((group) => group!)
//           .toList();
//     }

//     return groups;
//   }

//   @override
//   Future<void> deleteGroup(String groupId) async {
//     try {
//       // Fetch the list of groups from the database
//       CollectionReference groupEventCollections =
//           FirebaseFirestore.instance.collection('groups');

//       // Delete the group document
//       await groupEventCollections.doc(groupId).delete();

//       // Fetch the list of users from the group
//       DocumentSnapshot groupSnapshot =
//           await groupEventCollections.doc(groupId).get();

//       // The usernames of the users
//       List<String> groupUserNames = [];

//       // This is the list of users
//       List<dynamic> usersList = groupSnapshot['users'];

//       // Populate the list of usernames
//       for (var userObj in usersList) {
//         String userName = userObj[
//             'userName']; // Assuming 'userName' is the key in your user object
//         groupUserNames.add(userName);
//       }

//       User? currentUser = await getCurrentUser();

//       // Delete the group's events collection
//       await groupEventCollections.doc(groupId).collection('events').get().then(
//         (snapshot) {
//           for (DocumentSnapshot doc in snapshot.docs) {
//             doc.reference.delete();
//           }
//         },
//       );

//       // Update the user's groups Id in the database
//       for (String userName in groupUserNames) {
//         User? user = await getUserByUserName(userName);
//         if (user != null) {
//           user.groupIds.remove(groupId);
//           if (user.userName == currentUser!.userName) {
//             await updateUser(user);
//           }
//         }
//       }

//       User? _currentUser = await getCurrentUser();

//       // Fetch the updated list of groups and update the state
//       List<Group> fetchedGroups = await fetchUserGroups(_currentUser!.groupIds);
//       _providerManagement!.updateGroupStream(fetchedGroups);
//     } catch (error) {
//       // Handle the error
//       print("Error deleting group: $error");
//     }
//   }

//   /// Overrides the method to remove a user from a group in Firestore.
//   ///
//   /// This method removes the specified [user] from the [group] by updating both
//   /// the user and the group documents in Firestore.
//   ///
//   /// Parameters:
//   /// - [user]: The user to be removed from the group.
//   /// - [group]: The group from which the user will be removed.
//   ///
//   /// Returns:
//   /// - A `Future<void>` representing the asynchronous operation.
//   ///
//   /// Throws:
//   /// - An error if any error occurs during the removal process.
//   @override
//   Future<void> removeUserInGroup(User user, Group group) async {
//     try {
//       // Remove the user from the group's list
//       List<User> updatedUsers =
//           group.users.where((u) => u.name != user.name).toList();
//       group.users = updatedUsers;

//       // Remove the group ID from the user's data
//       user.groupIds.remove(group.id);

//       // Remove the user from the user roles list in the group
//       group.userRoles.remove(user.userName);

//       //Remove the user from the invited list in the group
//       group.invitedUsers?.remove(user.userName);

//       // Update both the user and the group in Firestore
//       await updateUser(user);

//       //Let's use the provider to remove the group from the user groups list
//       _providerManagement!.removeGroup(group);

//       //We proceed to send a notification based on the user and the group
//       await leavingNotificationForGroup(group);
//     } catch (error) {
//       print('Error removing user from group: $error');
//     }
//   }

//   @override
//   Future<User> getOwnerFromGroup(Group group) async {
//     try {
//       // 1. Query Firestore to retrieve the owner's user document.
//       DocumentSnapshot userDocSnapshot = await _firestore
//           .collection(
//               'users') // Assuming 'users' is the collection name for users
//           .doc(group
//               .ownerId) // Replace with the actual path to the owner's user document
//           .get();

//       // 2. Convert Firestore document data to JSON format.
//       Map<String, dynamic> userData =
//           userDocSnapshot.data() as Map<String, dynamic>;

//       // 3. Create a User object using the user.fromJson method.
//       User owner = User.fromJson(
//           userData); // Replace with your actual JSON parsing logic

//       return owner;
//     } catch (e) {
//       // Handle any errors that may occur during the process.
//       print("Error retrieving owner: $e");
//       rethrow; // Rethrow the error for higher-level handling if needed.
//     }
//   }

//   @override
//   Future<Event?> getEventFromGroupById(String eventId, String groupId) async {
//     try {
//       Group? fetchedGroup = await getGroupFromId(groupId);

//       if (fetchedGroup != null) {
//         Event? foundEvent = fetchedGroup.calendar.events.firstWhere(
//           (event) => event.id == eventId,
//         );

//         return foundEvent;
//       }
//     } catch (e) {
//       print('Error: $e');
//       rethrow;
//     }
//     return null;
//   }

//   // ** HANDLE USER DATA ***

//   /** Here I update the user and also if he is in groups  */
//   @override
//   Future<String> updateUser(User user) async {
//     try {
//       CollectionReference userCollection =
//           FirebaseFirestore.instance.collection('users');

//       QuerySnapshot userQuerySnapshot = await userCollection
//           .where('email', isEqualTo: user.email)
//           .limit(1)
//           .get();

//       if (userQuerySnapshot.docs.isNotEmpty) {
//         DocumentReference userRef = userQuerySnapshot.docs.first.reference;

//         await userRef.update(user.toJson()); // Update the user document

//         User? currentUser = await getCurrentUser();

//         if (currentUser != null && currentUser.id == user.id) {
//           _authService.costumeUser = user;

//           // Update the user in his groups
//           if (user.groupIds.isNotEmpty) {
//             updateUserInGroups(user);
//           }
//         }

//         // Use _providerManagement here
//         if (_providerManagement != null) {
//           _providerManagement!.updateUser(user);
//           // _providerManagement!.setGroups;
//         }

//         return 'User has been updated';
//       }

//       return 'User not found';
//     } catch (error) {
//       throw Exception('Error updating user in Firestore: $error');
//     }
//   }

//   @override
//   Future<User?> getUserById(String userId) async {
//     try {
//       QuerySnapshot querySnapshot = await _firestore
//           .collection('users')
//           .where('id', isEqualTo: userId)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         // We return the first user found with the given custom ID
//         DocumentSnapshot userSnapshot = querySnapshot.docs.first;
//         Map<String, dynamic> userData =
//             userSnapshot.data() as Map<String, dynamic>;
//         return User.fromJson(userData);
//       } else {
//         // User not found
//         return null;
//       }
//     } catch (error) {
//       print('Error fetching user by custom ID: $error');
//       return null;
//     }
//   }

//   @override
//   Future<User?> getUserByName(String userName) async {
//     try {
//       QuerySnapshot querySnapshot = await _firestore
//           .collection('users')
//           .where('userName', isEqualTo: userName)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         // Assuming you want to return the first user found with the given username
//         DocumentSnapshot userSnapshot = querySnapshot.docs.first;
//         Map<String, dynamic> userData =
//             userSnapshot.data() as Map<String, dynamic>;
//         return User.fromJson(userData);
//       } else {
//         // User not found
//         return null;
//       }
//     } catch (error) {
//       print('Error fetching user by name: $error');
//       return null;
//     }
//   }

//   @override
//   Future<Event?> getEventFromUserById(User user, String eventId) async {
//     try {
//       // First, you should fetch the user's list of events.
//       List<Event> userEvents =
//           user.events; // Assuming User has a list of events.

//       // Find the event you're looking for based on the provided eventIdToRetrieve.
//       Event? event = userEvents.firstWhere(
//         (event) =>
//             event.id ==
//             eventId, // Provide a default value if the event is not found.
//       );

//       return event;
//     } catch (e) {
//       print("Error while getting event: $e");
//       return null;
//     }
//   }

//   Future<User?> getUserByUserName(String userName) async {
//     try {
//       // 1. Query Firestore to retrieve the user document with the matching username.
//       QuerySnapshot userQuerySnapshot = await _firestore
//           .collection('users')
//           .where('userName', isEqualTo: userName)
//           .get();

//       // 2. Check if a user with the given username exists.
//       if (userQuerySnapshot.docs.isNotEmpty) {
//         // 3. Get the first document (assuming usernames are unique) and convert it to JSON format.
//         Map<String, dynamic> userData =
//             userQuerySnapshot.docs.first.data() as Map<String, dynamic>;

//         // 4. Create a User object using the `fromJson` method.
//         User user =
//             User.fromJson(userData); // Replace with your JSON parsing logic

//         return user;
//       } else {
//         // User with the provided username was not found.
//         return null;
//       }
//     } catch (e) {
//       // Handle any errors that may occur during the process.
//       print("Error retrieving user: $e");
//       rethrow; // Rethrow the error for higher-level handling if needed.
//     }
//   }

//   @override
//   Future<void> changeUsername(String newUserName) async {
//     try {
//       // Get the current user
//       final user = _authService.costumeUser;

//       if (user != null) {
//         // Check if the new username is already taken
//         bool isUsernameTaken = await _isUsernameAlreadyTaken(newUserName);

//         if (isUsernameTaken) {
//           // Handle the case where the username is already taken
//           // You can throw an exception, log the error, or handle it as needed
//           print('Error: Username is already taken. Choose a different one.');
//           throw UsernameAlreadyTakenException();
//         }

//         // Update the userName field in Firestore
//         await _firestore.collection('users').doc(user.id).update({
//           'userName': newUserName,
//         });

//         // Optionally, update any other fields in your custom user object
//         user.userName = newUserName;

//         // Save the updated user object to your AuthService or wherever it is managed
//         _authService.costumeUser = user;

//         _providerManagement!.updateUser(user);
//       }
//     } catch (error) {
//       // Handle errors, you may want to log or rethrow the error
//       print("Error changing user name: $error");
//       throw error;
//     }
//   }

// // Function to check if a username is already taken
//   Future<bool> _isUsernameAlreadyTaken(String username) async {
//     try {
//       // Query Firestore to check if the username exists in the 'users' collection
//       QuerySnapshot querySnapshot = await _firestore
//           .collection('users')
//           .where('userName', isEqualTo: username)
//           .get();

//       // If the querySnapshot is not empty, the username is already taken
//       return querySnapshot.docs.isNotEmpty;
//     } catch (error) {
//       // Handle errors, log or rethrow the error as needed
//       print("Error checking if username is already taken: $error");
//       throw error;
//     }
//   }
// }
