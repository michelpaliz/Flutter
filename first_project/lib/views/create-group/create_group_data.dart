import 'dart:io';
import 'package:first_project/enums/color_properties.dart';
import 'package:first_project/models/calendar.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/utils/utilities.dart';
import 'package:first_project/views/create-group/create_group_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateGroupData extends StatefulWidget {
  @override
  _CreateGroupDataState createState() => _CreateGroupDataState();
}

class _CreateGroupDataState extends State<CreateGroupData> {
  String _groupName = '';
  String _groupDescription = '';
  XFile? _selectedImage;
  TextEditingController _searchController = TextEditingController();
  StoreService _storeService = StoreService.firebase();
  User? _currentUser = AuthService.firebase().costumeUser;
  Map<String, String> _userRoles = {}; // Map to store user roles
  late List<User> _userInGroup;

  @override
  void initState() {
    super.initState();
    // Initialize instance variables in the initState method
    _groupName = '';
    _groupDescription = '';
    _selectedImage = null;
    _userRoles[_currentUser!.userName] = 'Administrator';
    _userInGroup = [];
  }

  void _updateUserInGroup(List<User> updatedData) {
    setState(() {
      _userInGroup = updatedData;
    });
  }

  void _onDataChanged(
      List<User> updatedUserInGroup, Map<String, String> updatedUserRoles) {
    // Print the new data before updating the state
    print('Updated User In Group: $updatedUserInGroup');
    print('Updated User Roles: $updatedUserRoles');

    // Update the state of CreateGroupData with the received data
    setState(() {
      _userRoles = updatedUserRoles;
    });

    // Update the _userInGroup list using the helper function
    _updateUserInGroup(updatedUserInGroup);
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });
    }
  }

  void onSearch(String query) {
    // You can perform your search action with the 'query' parameter
    print('Search query: $query');
    // Add your logic here
  }

  void _saveGroup() {
    if (_groupName.isNotEmpty && _groupDescription.isNotEmpty) {
      // Both fields are not empty, you can proceed with saving the group
      // Add your logic to save the group here
      print('Group name: $_groupName');
      print('Group description: $_groupDescription');
    } else {
      // Display an error message or prevent the action
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Group name and description are required.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  /** Remove the user using the index of the list  */
  void _removeUser(String fetchedUserName) {
    // Check if the user is the current user before attempting to remove
    if (fetchedUserName == _currentUser?.userName) {
      print('Cannot remove current user: $fetchedUserName');
      // Show a message to the user that they cannot remove themselves
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot remove yourself from the group.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print('This is the group $_userInGroup');

    int indexToRemove = _userInGroup.indexWhere(
        (u) => u.userName.toLowerCase() == fetchedUserName.toLowerCase());

    if (indexToRemove != -1) {
      List<User> updatedUserInGroup = List.from(_userInGroup);
      updatedUserInGroup.removeAt(indexToRemove);
      _updateUserInGroup(updatedUserInGroup);
      setState(() {
        _userRoles.remove(fetchedUserName);
      });
      print('Remove user: $fetchedUserName');
    } else {
      print('User not found in the group: $fetchedUserName');
    }
  }

  /** Create the group, just insert the name for the group */
  void creatingGroup() async {
    if (_groupName.trim().isEmpty) {
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
    Calendar? calendar = new Calendar(randomId, _groupName,
        events: null); // Assuming Calendar is defined elsewhere.

    // We are gonna only add the current user to the group, the others would need to accept the group's notification.

    List<User> users = [];
    users.add(_currentUser!);

    //We assign the groupId to the current user
    _currentUser!.groupIds.add(groupId);

    // Create the group object with the appropriate attributes
    Group group = Group(
        id: groupId,
        groupName: _groupName,
        ownerId: _currentUser!.id,
        userRoles: _userRoles,
        calendar: calendar,
        // users: userInGroup, // Include the list of users in the group
        users: users,
        createdTime: DateTime.now(),
        description: '',
        photo: '');

    //** UPLOAD THE GROUP CREATED TO FIRESTORE */
    _storeService.addGroup(group);
    //let's update the current user and add the new group id in his list.
    _storeService.updateUser(_currentUser!);
    // Show a success message using a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group created successfully!')),
    );

    //** AFTER CREATING THE GROUP WE PROCEED TO CREATE THE NOTIFICATION */

    //Create the title message of the notification
    String notificationTitle =
        '${_currentUser?.name.toUpperCase()} invited you to a group';
    // Create the notification message for the group
    String notificationMessage =
        '${_currentUser?.name.toUpperCase()} invited you to this Group: ${group.groupName}';
    String notificationQuestion = 'Would you like to join to this group ?';

    print(_userInGroup);

    // Add a new notification for each user in the group
    for (User user in _userInGroup) {
      if (user.id != _currentUser!.id) {
        // Compare using user IDs
        NotificationUser notification = NotificationUser(
            id: groupId,
            ownerId: _currentUser!.id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Group Data'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                    child: Center(
                      child: _selectedImage != null
                          ? Image.file(File(_selectedImage!.path))
                          : Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Put an image for your group',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) => _groupName = value,
                    decoration: InputDecoration(
                      labelText: 'Enter group name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) => _groupDescription = value,
                    decoration: InputDecoration(
                      labelText: 'Enter group description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Add people to your group',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Text(
                                        "ADD A NEW USER TO YOUR GROUP",
                                        style: TextStyle(
                                          fontFamily: 'Lato',
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CreateGroupSearchBar(
                                      onDataChanged: _onDataChanged,
                                      user: _currentUser,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Close"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Center(
                        child: Text('Add user'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                if (_userRoles.isNotEmpty)
                  Column(
                    children: _userRoles.keys.map((userName) {
                      final roleValue = _userRoles[userName];

                      return FutureBuilder<User?>(
                        future: _storeService.getUserByName(userName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Loading indicator
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            final user = snapshot.data;

                            return ListTile(
                              title: Text(userName),
                              subtitle: Text(roleValue!),
                              leading: CircleAvatar(
                                radius: 30, // Adjust the size as needed
                                backgroundImage:
                                    Utilities.buildProfileImage(user?.photoUrl),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  // Add your remove action here
                                  setState(() {
                                    _removeUser(userName);
                                  });
                                },
                                child: Icon(
                                  Icons.clear,
                                  color: Colors.red,
                                ),
                              ),
                              onTap: () {
                                // Add any action you want when the role is tapped
                              },
                            );
                          } else {
                            return Text('User not found');
                          }
                        },
                      );
                    }).toList(),
                  )
                else
                  Text("No user roles available"),
                SizedBox(
                    height:
                        15), // Add spacing between the user roles list and the button
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: TextButton(
                onPressed: () {
                  _saveGroup();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group_add_rounded),
                    SizedBox(width: 8),
                    Text('Save Group', style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ColorProperties.defaultButton(),
              ),
            )));
  }
}
