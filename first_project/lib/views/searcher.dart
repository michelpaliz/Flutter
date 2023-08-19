import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/views/create_group.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/calendar.dart';
import '../models/group.dart';
import '../models/notification_user.dart';
import '../models/user.dart';
import '../services/auth/implements/auth_service.dart';
import '../services/firestore/implements/firestore_service.dart';

class Searcher extends StatefulWidget {
  const Searcher({Key? key}) : super(key: key);

  @override
  State<Searcher> createState() => _SearcherState();
}

class _SearcherState extends State<Searcher> {
  // ** Variables ** //
  List<String> searchResults = [];
  String groupName = '';
  List<String> selectedUsers = [];
  List<User> userInGroup = []; // List to store selected users
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  String? clickedUser;
  StoreService storeService =
      StoreService.firebase(); // Create an instance of StoreService
  String? selectedPickerRule;
  Map<String, String> userRoles = {}; // Map to store user roles

  void main() {
    runApp(MaterialApp(
      home: Searcher(),
    ));
  }

  //** LOGIC FOR THE VIEW */
  /** Search a user by inserting his name */
  void searchUser(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: username)
          .get();

      final List<String> foundUsers =
          querySnapshot.docs.map((doc) => doc['name'] as String).toList();

      setState(() {
        searchResults = foundUsers;
      });
    } catch (e) {
      print('Error searching for users: $e');
    }
  }

  /** Add an user using the selectedUsers list */
  void addUser(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User with the provided username found
        final userData = querySnapshot.docs.first.data();

        final user = User.fromJson(userData);

        setState(() {
          if (!selectedUsers.contains(user.name)) {
            selectedUsers.add(user.name);
            userInGroup.add(user);
          }
        });

        print('User added: $user');
      } else {
        // User with the provided username not found
        print('User not found for username: $username');
      }
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  /** Remove the user using the index of the list  */
  void removeUser(String user) {
    // Find the index of the User object in the userInGroup list that matches the username
    int indexToRemove = userInGroup.indexWhere((u) => u.name == user);

    if (indexToRemove != -1) {
      setState(() {
        userInGroup.removeAt(indexToRemove);
        selectedUsers.remove(user);
      });
      print('Remove user: $user');
    } else {
      print('User not found in the group: $user');
    }
  }

  /** Create the group, just insert the name for the group */
  void creatingGroup() async {
    if (groupName.trim().isEmpty) {
      // Show a SnackBar with the error message when the group name is empty or contains only whitespace characters
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group name cannot be empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    //** CREATING THE GROUP FOR THE MEMBERS */
    // Generate a unique ID for the group (You can use any method to generate an ID, like a timestamp-based ID, UUID, etc.)
    String groupId = UniqueKey().toString();

    // Generate a random ID using Firestore
    final uuid = Uuid();
    final randomId = uuid.v4();

    // Create an instance of the Calendar class or any other logic required to initialize the calendar.
    Calendar? calendar = new Calendar(randomId, groupName,
        events: null); // Assuming Calendar is defined elsewhere.

    // Call getCurrentUserAsCustomeModel to populate _currentUser
    User? currentUser =
        await AuthService.firebase().getCurrentUserAsCustomeModel();

    String? ownerId = currentUser?.id;

    // Create the userRoles map and assign the group owner to the 'owner' role
    Map<String, String> userRoles = {};

    // Assign other selected users to the 'member' role in the userRoles map
    for (String userId in selectedUsers) {
      userRoles[userId] = 'member';
    }

    // Create the group object with the appropriate attributes
    Group group = Group(
      id: groupId,
      groupName: groupName,
      ownerId: ownerId,
      userRoles: userRoles,
      calendar: calendar,
      users: userInGroup, // Include the list of users in the group
    );

    // Create the notification message for the group
    String notificationMessage =
        '${currentUser?.name.toUpperCase()} invited you to this Group: ${group}.}';

    // Add a new notification for each user in the group
    for (User user in userInGroup) {
      NotificationUser notification = NotificationUser(
        id: UniqueKey().toString(), // Generate a unique ID for the notification
        message: notificationMessage,
        timestamp:
            DateTime.now(), // Use the current timestamp for the notification
      );

      storeService.addNotification(user,
          notification); // Add the notification to the user's notifications list
    }

    //** UPLOAD THE GROUP CREATED TO FIRESTORE */
    storeService.addGroup(group);
    // Show a success message using a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group created successfully!')),
    );

    print('Creating group: ${userInGroup.toString()}');
  }

  //TODO: Move this function to the server side
  // Helper function to get the user document based on their name from Firestore`
  Future<DocumentSnapshot?> getUserFromName(String userName) async {
    QuerySnapshot querySnapshot =
        await usersCollection.where('name', isEqualTo: userName).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Assuming there is only one user with the given name, so we return the first document.
      return querySnapshot.docs.first;
    } else {
      return null;
    }
  }

  //* UI FOR THE VIEW /

  // Add this method to display the question and the horizontal list of selected users.
  Widget buildSelectedUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedUsers.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Center(
                child: Text(
                  "THESE ARE THE USERS SELECTED",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding:
                    const EdgeInsets.all(8.0), // Add padding around the list
                child: ListView.builder(
                  shrinkWrap: true, // Set shrinkWrap to true
                  itemCount: selectedUsers.length,
                  itemBuilder: (context, index) {
                    final selectedUser = selectedUsers[index];
                    final userRole = userRoles[selectedUser] ?? 'member';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedUser,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          DropdownButton<String>(
                            value: userRole,
                            items: <DropdownMenuItem<String>>[
                              DropdownMenuItem<String>(
                                value: 'administrator',
                                child: Text('Administrator'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'co-administrator',
                                child: Text('Co-Administrator'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'member',
                                child: Text('Member'),
                              ),
                            ],
                            onChanged: (newValue) {
                              setState(() {
                                userRoles[selectedUser] = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        else
          Center(
            child: Text(
              "No users selected.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Search'),
      ),
      body: SingleChildScrollView(
        // Wrap the content in a SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => groupName = value,
                decoration: InputDecoration(
                  labelText: 'Enter group name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => searchUser(value),
                decoration: InputDecoration(
                  labelText: 'Search for a person',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: searchResults.map((user) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(user),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            clickedUser = user;
                          });
                          addUser(user); // Call the addUser function here
                        },
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            clickedUser =
                                null; // Reset clickedUser when removing the user
                          });
                          removeUser(user); // Call the removeUser function here
                        },
                        icon: Icon(Icons.remove),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            // Display the selected users in the horizontal list
            buildSelectedUsersList(),
            SizedBox(height: 5),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    creatingGroup();
                    // navigateToNextView(userInGroup);
                  },
                  child: Text("Create Group"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
