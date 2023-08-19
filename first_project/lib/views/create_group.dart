// import 'package:first_project/models/user.dart';
// import 'package:flutter/material.dart';

// class CreateGroup extends StatefulWidget {
//   const CreateGroup({super.key, required List<User> groupMembers});

//   @override
//   State<CreateGroup> createState() => _CreateGroupState();
// }

// class _CreateGroupState extends State<CreateGroup> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }

//   //* LOGIC FOR THE VIEW *//
//   /** Create the group, just insert the name for the group */
//   void creatingGroup() async {
//     if (groupName.trim().isEmpty) {
//       // Show a SnackBar with the error message when the group name is empty or contains only whitespace characters
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Group name cannot be empty'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     //** CREATING THE GROUP FOR THE MEMBERS */
//     // Generate a unique ID for the group (You can use any method to generate an ID, like a timestamp-based ID, UUID, etc.)
//     String groupId = UniqueKey().toString();

//     // Generate a random ID using Firestore
//     final uuid = Uuid();
//     final randomId = uuid.v4();

//     // Create an instance of the Calendar class or any other logic required to initialize the calendar.
//     Calendar? calendar = new Calendar(randomId, groupName,
//         events: null); // Assuming Calendar is defined elsewhere.

//     // Call getCurrentUserAsCustomeModel to populate _currentUser
//     User? currentUser =
//         await AuthService.firebase().getCurrentUserAsCustomeModel();

//     String? ownerId = currentUser?.id;

//     // Create the userRoles map and assign the group owner to the 'owner' role
//     Map<String, String> userRoles = {};

//     // Assign other selected users to the 'member' role in the userRoles map
//     for (String userId in selectedUsers) {
//       userRoles[userId] = 'member';
//     }

//     //** THIS WAS FOR THE PREVIOUS LOGIC WHEN WE WANTED TO SELECT AN SPECIFIC USER FOR THE CALENDAR */

//     // Create the group object with the appropriate attributes
//     Group group = Group(
//       id: groupId,
//       groupName: groupName,
//       ownerId: ownerId,
//       userRoles: userRoles,
//       calendar: calendar,
//       users: userInGroup, // Include the list of users in the group
//     );

//     // Create the notification message for the group
//     String notificationMessage =
//         '${currentUser?.name.toUpperCase()} invited you to this Group: ${group}.}';

//     // Add a new notification for each user in the group
//     for (User user in userInGroup) {
//       NotificationUser notification = NotificationUser(
//         id: UniqueKey().toString(), // Generate a unique ID for the notification
//         message: notificationMessage,
//         timestamp:
//             DateTime.now(), // Use the current timestamp for the notification
//       );

//       storeService.addNotification(user,
//           notification); // Add the notification to the user's notifications list
//     }

//     //** UPLOAD THE GROUP CREATED TO FIRESTORE */
//     storeService.addGroup(group);
//     // Show a success message using a SnackBar
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Group created successfully!')),
//     );

//     print('Creating group: ${userInGroup.toString()}');
//   }
// }