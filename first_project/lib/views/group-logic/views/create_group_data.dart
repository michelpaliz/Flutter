import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:first_project/enums/color_properties.dart';
import 'package:first_project/models/calendar.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:first_project/views/group-logic/create_group_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreateGroupData extends StatefulWidget {
  @override
  _CreateGroupDataState createState() => _CreateGroupDataState();
}

class _CreateGroupDataState extends State<CreateGroupData> {
  String _groupName = '';
  String _groupDescription = '';
  XFile? _selectedImage;
  // late FirestoreService _storeService;
  User? _currentUser = AuthService.firebase().costumeUser;
  Map<String, String> _userRoles = {}; // Map to store user roles
  late List<User> _usersInGroup;
  UserService _userService = UserService();
  UserManagement? _userManagement;
  GroupManagement? _groupManagement;
  late NotificationManagement _notificationManagement;

  @override
  void initState() {
    super.initState();
    _groupName = '';
    _groupDescription = '';
    _selectedImage = null;
    _userRoles[_currentUser!.userName] = 'Administrator';
    _usersInGroup = [];
  }

  void _updateUserInGroup(List<User> updatedData) {
    setState(() {
      _usersInGroup = updatedData;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notificationManagement =
        Provider.of<NotificationManagement>(context, listen: false);
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
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

  //*** GROUP DATA FUNCTIONS TO CREATE GROUP */

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

  /** Remove the user using the index of the list  */
  void _removeUser(String fetchedUserName) {
    // Check if the user is the current user before attempting to remove
    if (fetchedUserName == _currentUser?.userName) {
      print('Cannot remove current user: $fetchedUserName');
      // Show a message to the user that they cannot remove themselves
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotRemoveYourself),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print('This is the group $_usersInGroup');

    int indexToRemove = _usersInGroup.indexWhere(
        (u) => u.userName.toLowerCase() == fetchedUserName.toLowerCase());

    if (indexToRemove != -1) {
      List<User> updatedUserInGroup = List.from(_usersInGroup);
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

  //Save the group but first send the data to firestore
  void _saveGroup() async {
    if (_groupName.isNotEmpty && _groupDescription.isNotEmpty) {
      // Show a loading indicator while the group is being created
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      try {
        bool groupCreated =
            await _creatingGroup(); // Call _creatingGroup and await the result

        if (mounted) {
          Navigator.of(context)
              .pop(); // Close the loading dialog if the widget is still mounted

          if (groupCreated) {
            // Group creation was successful, show a success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.groupCreated),
              ),
            );

            // Navigate back to the previous screen
            Navigator.of(context).pop();
          } else {
            // Group creation failed, show an error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(AppLocalizations.of(context)!.failedToCreateGroup),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context)
              .pop(); // Ensure the dialog is closed even on error

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.failedToCreateGroup),
            ),
          );
        }

        print("Error in _saveGroup: $e");
      }
    } else {
      // Display an error message or prevent the action
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text(AppLocalizations.of(context)!.requiredTextFields),
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
  }

  Future<bool> _creatingGroup() async {
    // Check if the group name is empty or only contains whitespace
    if (_groupName.trim().isEmpty) {
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.groupNameRequired),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Exit early since group creation can't proceed without a name
    }

    try {
      // Step 1: Generate a unique ID for the group
      String groupId = Uuid().v4().substring(0, 10);

      // Step 2: Get the current user's data from the server
      User userServer =
          await _userService.getUserByUsername(_currentUser!.userName);

      // Step 3: Create a list with the current user as the only initial member of the group
      List<User> users = [userServer];

      // Step 4: Upload the group image if one has been selected
      String imageURL = "";
      if (_selectedImage != null) {
        imageURL =
            await Utilities.pickAndUploadImageGroup(groupId, _selectedImage);
      }

      // Step 5: Define the admin of the group as the current user
      Map<String, String> adminUsersJson = {_currentUser!.userName: 'Administrator'};

      // Step 6: Generate a unique ID for the calendar associated with the group
      String calendarId = Uuid().v4().substring(0, 10);

      // Step 7: Create the Group object with all necessary details
      Group newGroup = Group(
        id: groupId,
        name: _groupName,
        ownerId: _currentUser!.id, // Current user is the owner and admin
        userRoles: adminUsersJson, // Only the current user is an admin
        calendar: new Calendar(calendarId, _groupName),
        userIds: [
          _currentUser!.id
        ], // The current user is the only member for now
        invitedUsers: null, // Invitations will be created next
        createdTime: DateTime.now(),
        description: _groupDescription,
        photo: imageURL,
      );

      // Step 8: Create invitations for other users (excluding the admin)
      Map<String, UserInviteStatus> invitations = {};
      _userRoles.forEach((userId, role) {
        if (userId != _currentUser!.id) {
          // Exclude the admin from invitations
          invitations[userId] = UserInviteStatus(
            id: newGroup.id,
            role: role,
            invitationAnswer: null,
            sendingDate: DateTime.now(),
            attempts: 1,
          );
        }
      });

      // Step 9: Assign the invitations to the group
      newGroup.invitedUsers = invitations;

      // Step 10: Upload the new group to Firestore and return the result
      bool result = await _groupManagement!
          .addGroup(newGroup, _notificationManagement, _userManagement!, {});

      devtools.log("THIS IS RESULT ${result}");

      return result; // Return true if the group was successfully created
    } catch (e) {
      // Log any errors that occur during the process
      print("Error creating group: $e");
      return false; // Return false to indicate that group creation failed
    }
  }

  @override
  Widget build(BuildContext context) {
    final TITLE_MAX_LENGTH = 25;
    final DESCRIPTION_MAX_LENGTH = 100;
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.groupData),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                //*PICK IMAGE**
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50, // Adjust the size as needed
                    backgroundColor:
                        _selectedImage != null ? Colors.transparent : null,
                    backgroundImage: _selectedImage != null
                        ? FileImage(File(_selectedImage!.path))
                        : null,
                    child: _selectedImage == null
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
                  AppLocalizations.of(context)!.putGroupImage,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 10),

                //** GENERATE THE GROUP'S NAME */
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      if (value.length <= 25) {
                        // Set your desired maximum length (e.g., 50)
                        _groupName = value;
                      }
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          TITLE_MAX_LENGTH), // Set the maximum length here
                    ],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!
                          .textFieldGroupName(TITLE_MAX_LENGTH),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                //** DESCRIPTION  */
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _groupDescription = value;
                      });
                    },
                    maxLines:
                        null, // Allow the text field to have unlimited lines
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          DESCRIPTION_MAX_LENGTH), // Adjust the limit based on an average word length
                    ],
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!
                          .textFieldDescription(DESCRIPTION_MAX_LENGTH),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                //** ADD PEOPLE INTO THE GROUP */
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.addPplGroup,
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
                                        AppLocalizations.of(context)!
                                            .addNewUser,
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
                                        group: null),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                        AppLocalizations.of(context)!.close),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Center(
                        child: Text(AppLocalizations.of(context)!.addUser),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                //*SELECT USER RULES

                if (_userRoles.isNotEmpty)
                  Column(
                    children: _userRoles.keys.map((userName) {
                      final roleValue = _userRoles[userName];
                      if (roleValue == "Administrator") {
                        return FutureBuilder<User?>(
                          // future: _storeService.getUserByName(userName),
                          // future: _userService.getUserByUsername(userName),
                          future: _userService.getUserByUsername(userName),
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
                                  backgroundImage: Utilities.buildProfileImage(
                                      user?.photoUrl),
                                ),
                                onTap: () {
                                  // Add any action you want when the role is tapped
                                },
                              );
                            } else {
                              return Text(
                                  AppLocalizations.of(context)!.userNotFound);
                            }
                          },
                        );
                      } else {
                        return FutureBuilder<User?>(
                          // future: _storeService.getUserByName(userName),
                          future: _userService.getUserByUsername(userName),
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
                                  backgroundImage: Utilities.buildProfileImage(
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
                                  // Add any action you want when the user is tapped
                                },
                              );
                            } else {
                              return Text(
                                  AppLocalizations.of(context)!.userNotFound);
                            }
                          },
                        );
                      }
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
        //** SAVE CREATED GROUP */
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
                    Text(AppLocalizations.of(context)!.saveGroup,
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ColorProperties.defaultButton(),
              ),
            )));
  }
}