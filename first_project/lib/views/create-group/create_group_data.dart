import 'dart:io';
import 'package:first_project/enums/color_properties.dart';
import 'package:first_project/models/calendar.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/styles/button_styles.dart';
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
  
  set userRoles(Map<String, String> userRoles) {}
  
  set userInGroup(List<User> userInGroup) {}

  void onDataChanged(List<User> userInGroup, Map<String, String> userRoles) {
    // Update the state of CreateGroupData with the received data
    setState(() {
      this.userInGroup = userInGroup;
      this.userRoles = userRoles;
    });
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

  void goToAnotherView() {
    // Navigate to another view and pass the group name and group description as arguments.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateGroupSearchBar(),
      ),
    );
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
        '${_currentUser?.name.toUpperCase()} invited you to this Group: ${group._groupName}}';

    String notificationQuestion = 'Would you like to join to this group ?';

    print(userInGroup);

    // Add a new notification for each user in the group
    for (User user in userInGroup) {
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
        // Wrap the content with SingleChildScrollView
        child: Padding(
          // Wrap the Column with Padding
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: GestureDetector(
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
              ),
              SizedBox(height: 5),
              Text(
                'Put an image for your group if you want',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) => _groupName = value,
                  decoration: InputDecoration(
                    labelText: 'Enter group name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: (value) => _groupDescription = value,
                  decoration: InputDecoration(
                    labelText: 'Enter group description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(height: 5),
              CreateGroupSearchBar(
                onDataChanged:
                    onDataChanged, // Pass the callback function to CreateGroupSearchBar
              ),
              SizedBox(height: 10),
              TextButton(
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
                  style: ColorProperties.defaultButton())
            ],
          ),
        ),
      ),
    );
  }
}
