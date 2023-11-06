import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/views/service_provider/provider_management.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/calendar.dart';
import '../../models/group.dart';
import '../../models/notification_user.dart';
import '../../models/user.dart';
import '../../services/auth/implements/auth_service.dart';
import '../../services/firestore/implements/firestore_service.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({Key? key}) : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  // ** Variables ** //
  List<String> searchResults = [];
  String groupName = '';
  List<String> selectedUsers = [];
  List<User> userInGroup = []; // List to store selected users
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');
  String? clickedUser;
  late StoreService _storeService; // Create an instance of StoreService
  Map<String, String> userRoles = {}; // Map to store user roles
  User? currentUser = null;

  void main() {
    runApp(MaterialApp(
      home: CreateGroup(),
    ));
  }

  @override
  void initState() {
    super.initState();
    AuthService.firebase().generateUserCustomeModel().then((User? fetchedUser) {
      if (fetchedUser != null) {
        setState(() {
          currentUser = fetchedUser;
          userInGroup = [currentUser!];
          selectedUsers = [currentUser!.name];
          // Set the default role to administrator for the current user
          userRoles[currentUser!.name] = 'Administrator';
        });
      }
    });
  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Access the inherited widget in the didChangeDependencies method.
    final providerManagement = Provider.of<ProviderManagement>(context);

    // Initialize the _storeService using the providerManagement.
    _storeService = StoreService.firebase(providerManagement);
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

  /** Remove the user using the index of the list  */
  void removeUser(String user) {
    // Check if the user is the current user before attempting to remove
    if (user == currentUser?.name) {
      print('Cannot remove current user: $user');
      // Show a message to the user that they cannot remove themselves
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot remove yourself from the group.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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

    //** CREATING THE GROUP*/
    // Generate a unique ID for the group (You can use any method to generate an ID, like a timestamp-based ID, UUID, etc.)
    String groupId = UniqueKey().toString();

    // Generate a random ID using Firestore
    final uuid = Uuid();
    final randomId = uuid.v4();

    // Create an instance of the Calendar class or any other logic required to initialize the calendar.
    Calendar? calendar = new Calendar(randomId, groupName,
        events: null); // Assuming Calendar is defined elsewhere.

    // We are gonna only add the current user to the group, the others would need to accept the group's notification.

    List<User> users = [];
    users.add(currentUser!);

    //We assign the groupId to the current user
    currentUser!.groupIds.add(groupId);

    // Create the group object with the appropriate attributes
    Group group = Group(
        id: groupId,
        groupName: groupName,
        ownerId: currentUser!.id,
        userRoles: userRoles,
        calendar: calendar,
        // users: userInGroup, // Include the list of users in the group
        users: users,
        createdTime: DateTime.now(),
        description: '',
        photo: '');

    //** UPLOAD THE GROUP CREATED TO FIRESTORE */
    _storeService.addGroup(group);
    //let's update the current user and add the new group id in his list.
    _storeService.updateUser(currentUser!);
    // Show a success message using a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group created successfully!')),
    );

    //** AFTER CREATING THE GROUP WE PROCEED TO CREATE THE NOTIFICATION */

    //Create the title message of the notification
    String notificationTitle =
        '${currentUser?.name.toUpperCase()} invited you to a group';
    // Create the notification message for the group
    String notificationMessage =
        '${currentUser?.name.toUpperCase()} invited you to this Group: ${group.groupName}}';

    String notificationQuestion = 'Would you like to join to this group ?';

    print(userInGroup);

    // Add a new notification for each user in the group
    for (User user in userInGroup) {
      if (user.id != currentUser!.id) {
        // Compare using user IDs
        NotificationUser notification = NotificationUser(
            id: groupId,
            ownerId: currentUser!.id,
            title: notificationTitle,
            message: notificationMessage,
            timestamp: DateTime.now(),
            hasQuestion: true,
            question: notificationQuestion,
            isAnswered: false);

        user.notifications.add(notification);
        user.hasNewNotifications = true;
        await _storeService.updateUser(user);
      }
    }
  }

  //TODO: Move this function to the server side
  // Helper function to get the user document based on their name from Firestore`
  Future<DocumentSnapshot?> _getUserFromName(String userName) async {
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
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
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
                          if (selectedUser == currentUser!.name)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                userRole,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            DropdownButton<String>(
                              value: userRole,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.black,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Administrator',
                                  child: Text('Administrator',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Co-Administrator',
                                  child: Text('Co-Administrator',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'member',
                                  child: Text('Member',
                                      style: TextStyle(fontSize: 14)),
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

            // "Create Group" button centered at the bottom
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () {
                  creatingGroup();
                  // navigateToNextView(userInGroup);
                },
                child: Text("Create Group"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
