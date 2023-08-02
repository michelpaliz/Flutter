import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/calendar.dart';
import '../models/group.dart';
import '../models/notification_user.dart';
import '../models/user.dart';
import '../services/auth/implements/auth_service.dart';

class Searcher extends StatefulWidget {
  const Searcher({Key? key}) : super(key: key);

  @override
  State<Searcher> createState() => _SearcherState();
}

class _SearcherState extends State<Searcher> {
  List<String> searchResults = [];
  String groupName = '';
  List<String> selectedUsers = [];
  List<User> userInGroup = []; // List to store selected users
  // Assuming you have a Firestore collection named 'users' containing user documents with 'name' field.
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  String? clickedUser;

  //** LOGIC FOR THE VIEW */

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
          selectedUsers.add(user.name);
          userInGroup.add(
              user); // Store the complete User object in the userInGroup list
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

    // Generate a unique ID for the group (You can use any method to generate an ID, like a timestamp-based ID, UUID, etc.)
    String groupId = UniqueKey().toString();

    // Create an instance of the Calendar class or any other logic required to initialize the calendar.
    Calendar calendar; // Assuming Calendar is defined elsewhere.

    // Get the current user
    User? user = AuthService.firebase().costumeUser;

    String? ownerId = user?.id;

    // Create the userRoles map and assign the group owner to the 'owner' role
    Map<String, String> userRoles = {};

    // Assign other selected users to the 'member' role in the userRoles map
    for (String userId in selectedUsers) {
      userRoles[userId] = 'member';
    }

    // Search for the user document in Firestore using their name (selectedUser)
    DocumentSnapshot? userSnapshot = await getUserFromName(clickedUser!);

    // Make sure the user with the given name exists in the Firestore database
    if (!userSnapshot!.exists) {
      // Show a SnackBar with an error message indicating the user was not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected user not found in the database'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get the user data from the userSnapshot and convert it to the desired object
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    // Example: Create a User object with the retrieved data
    User selectedUser = User.fromJson(userData);

    print('Creating group: ${selectedUser.toString()}');

    // Create the group object with the appropriate attributes
    Group group = Group(
      id: groupId,
      groupName: groupName,
      ownerId: ownerId,
      userRoles: userRoles,
      calendar: null,
      users: userInGroup, // Include the list of users in the group
    );

    // Create the notification message for the group
    String notificationMessage =
        'You have been added to the group ${group.groupName} (ID: ${group.id})';

    // Add a new notification for each user in the group

    for (User user in userInGroup) {
      NotificationUser notification = NotificationUser(
        id: UniqueKey().toString(), // Generate a unique ID for the notification
        message: notificationMessage,
        timestamp:
            DateTime.now(), // Use the current timestamp for the notification
      );

      user.addNotification(
          notification); // Add the notification to the user's notifications list
    }
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
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Who is going to share the calendar for the group?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue, // Change the text color to blue
            ),
          ),
        ),
        SizedBox(height: 10),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: selectedUsers.length,
            itemBuilder: (context, index) {
              final user = selectedUsers[index];
              return GestureDetector(
                onTap: () {
                  // Update the clickedUser when a user is clicked
                  setState(() {
                    clickedUser = user;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    // backgroundImage: AssetImage(
                    //     'path/to/avatar.png'), // Replace with the actual avatar image
                    radius: 30,
                    child: Text(
                      user,
                      style: TextStyle(
                        color: clickedUser == user
                            ? Color.fromARGB(255, 22, 245, 252)
                            : Color.fromARGB(255, 49, 45, 255),
                        fontWeight: clickedUser == user
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        if (clickedUser != null) ...[
          // Display the clicked user below the list
          Center(
            child: Column(
              children: [
                // Display the clicked user below the list
                Text(
                  "This is the one you chose: $clickedUser",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 15),
                // ElevatedButton(
                //   onPressed: () {
                //     // You can perform some action related to the clicked user here if needed
                //   },
                //   child: Text("Do something with $clickedUser"),
                // ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Search'),
      ),
      body: Column(
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
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final user = searchResults[index];
                return ListTile(
                  title: Text(user),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => addUser(user),
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () => removeUser(user),
                        icon: Icon(Icons.remove),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Display the selected users in the horizontal list
          buildSelectedUsersList(),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  creatingGroup();
                },
                child: Text("Create Group"),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Searcher(),
  ));
}
