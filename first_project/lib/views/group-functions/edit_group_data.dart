import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/enums/color_properties.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/provider/provider_management.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/my-lib/utilities.dart';
import 'package:first_project/views/group-functions/create_group_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditGroupData extends StatefulWidget {
  final Group group;

  EditGroupData({required this.group});

  @override
  _EditGroupDataState createState() => _EditGroupDataState();
}

class _EditGroupDataState extends State<EditGroupData> {
  String _groupName = '';
  String _groupDescription = '';
  XFile? _selectedImage;
  TextEditingController _searchController = TextEditingController();
  late StoreService _storeService;
  User? _currentUser = AuthService.firebase().costumeUser;
  Map<String, String> _userRoles = {}; // Map to store user roles
  late List<User> _userInGroup;
  late final Group _group;
  String _imageURL = "";

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _groupName = _group.groupName;
    _groupDescription = _group.description;
    if (_group.photo.isNotEmpty) {
      _imageURL = _group.photo;
    }
    _selectedImage = _group.photo.isEmpty
        ? null
        : XFile(
            _group.photo); // Initialize _selectedImage with the existing image

    // _userRoles[_currentUser!.userName] = 'Administrator';
    _userRoles = _group.userRoles;
    _userInGroup = _group.users;
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

  void _editGroup() async {
    if (_groupName.isNotEmpty && _groupDescription.isNotEmpty) {
      bool groupCreated =
          await _creatingGroup(); // Call _creatingGroup and await the result

      if (groupCreated) {
        // Group creation was successful, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group edited successfully!'),
          ),
        );
      } else {
        // Group creation failed, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to edit the group. Please try again.'),
          ),
        );
      }

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

  Future<bool> _creatingGroup() async {
    if (_groupName.trim().isEmpty) {
      // Show a SnackBar with the error message when the group name is empty or contains only whitespace characters
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group name cannot be empty'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Return false to indicate that the group creation failed.
    }

    try {
      //** CREATING THE GROUP*/

      //Now we are going to create the link of the image selected for the group

      if (_selectedImage != null) {
        _imageURL =
            await Utilities.pickAndUploadImageGroup(_group.id, _selectedImage);
      }

      // Create the group object with the appropriate attributes
      Group updateGroup = Group(
          id: _group.id,
          groupName: _groupName,
          ownerId: _currentUser!.id,
          userRoles: _userRoles,
          calendar: _group.calendar,
          users: _group.users, // Include the list of users in the group
          createdTime: DateTime.now(),
          description: _groupDescription,
          photo: _imageURL);

      //** UPLOAD THE GROUP CREATED TO FIRESTORE */
      await _storeService.updateGroup(updateGroup);

      // Show a success message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Group edited successfully!')),
      );

      return true; // Return true to indicate that the group creation was successful.
    } catch (e) {
      // Handle any errors that may occur during the process.
      print("Error creating group: $e");
      return false; // Return false to indicate that the group creation failed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderManagement>(
      builder: (context, providerManagement, child) {
        // final storeService = Provider.of<StoreService>(context);
        // _storeService = storeService;
        final TITLE_MAX_LENGHT = 25;
        final DESCRIPTION_MAX_LENGHT = 100;
        // Initialize _storeService using data from providerManagement.
        final providerData =
            providerManagement; // Adjust this to access the necessary data.
        _storeService = StoreService.firebase(providerData);

        // Rest of your build method...
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
                      child: CircleAvatar(
                        radius: 50, // Adjust the size as needed
                        backgroundColor:
                            _selectedImage != null ? Colors.transparent : null,
                        backgroundImage: _imageURL.isNotEmpty
                            ? CachedNetworkImageProvider(_imageURL)
                                as ImageProvider<Object>?
                            : _selectedImage != null
                                ? FileImage(File(_selectedImage!.path))
                                : null,
                        child: _imageURL.isEmpty && _selectedImage == null
                            ? Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.white,
                              )
                            : null, // Hide the Icon when there's an image
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
                        controller: TextEditingController(
                            text:
                                _groupName), // Use a TextEditingController to set the initial value
                        onChanged: (value) {
                          if (value.length <= 25) {
                            // Set your desired maximum length (e.g., 50)
                            _groupName = value;
                          }
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(TITLE_MAX_LENGHT),
                        ],
                        decoration: InputDecoration(
                          labelText:
                              'Enter group name (Limit: $TITLE_MAX_LENGHT characters)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller:
                            TextEditingController(text: _groupDescription),
                        onChanged: (value) {
                          setState(() {
                            _groupDescription = value;
                          });
                        },
                        maxLines:
                            null, // Allow the text field to have unlimited lines
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                              DESCRIPTION_MAX_LENGHT), // Adjust the limit based on an average word length
                        ],
                        decoration: InputDecoration(
                          labelText:
                              'Enter group description (Limit: $DESCRIPTION_MAX_LENGHT characters)',
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
                                        Utilities.buildProfileImage(
                                            user?.photoUrl),
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
                      _editGroup();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_add_rounded),
                        SizedBox(width: 8),
                        Text('Edit Group',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    style: ColorProperties.defaultButton(),
                  ),
                )));
      },
    );
  }
}
