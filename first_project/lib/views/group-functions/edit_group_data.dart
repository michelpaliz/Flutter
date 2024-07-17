import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:first_project/views/group-functions/create_group_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditGroupData extends StatefulWidget {
  final Group group;
  final List<User> users;

  EditGroupData({required this.group, required this.users});

  @override
  _EditGroupDataState createState() => _EditGroupDataState();
}

class _EditGroupDataState extends State<EditGroupData> {
  String _groupName = '';
  String _groupDescription = '';
  XFile? _selectedImage;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  User? _currentUser = AuthService.firebase().costumeUser;
  Map<String, String> _userUpdatedRoles = {}; // Map to store user roles
  Map<String, String> _userRolesAtFirst = {}; // Map to store user roles
  Map<String, UserInviteStatus> _usersInvitationStatus = {};
  late List<User> _usersInGroup = [];
  late final Group _group;
  String _imageURL = "";
  Map<String, Future<User?>> userFutures =
      {}; //Needs to be outside the build (ui state) to avoid loading
  ProviderManagement? _providerManagement;
  bool _showAccepted = true;
  bool _showPending = true;
  bool _showNotWantedToJoin = true;
  late String _currentUserRoleValue;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _groupName = _group.groupName;
    _groupDescription = _group.description;
    _descriptionController = TextEditingController(text: _groupDescription);
    _descriptionController.addListener(() {
      setState(() {
        _groupDescription = _descriptionController.text;
      });
    });

    if (_group.photo.isNotEmpty) {
      _imageURL = _group.photo;
    }
    _selectedImage = _group.photo.isEmpty
        ? null
        : XFile(
            _group.photo); // Initialize _selectedImage with the existing image
    _userUpdatedRoles = _group.userRoles;
    _userRolesAtFirst = _group.userRoles;
    _usersInGroup = widget.users;
    if (_group.invitedUsers != null && _group.invitedUsers!.isNotEmpty) {
      _usersInvitationStatus = _group.invitedUsers!;
    }

    if (_currentUser!.id == _group.ownerId) {
      _currentUserRoleValue = "Administrator";
    } else {
      for (var entry in _usersInvitationStatus.entries) {
        var userName = entry.key;
        var userInvitationStatus = entry.value;

        // Check if current user ID matches the userName in the map
        if (_currentUser!.id == userName) {
          // Do something with the userInvitationStatus
          _currentUserRoleValue = userInvitationStatus.role;
          break; // Exit the loop if the user is found
        }
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _providerManagement =
        Provider.of<ProviderManagement>(context, listen: false);
    _currentUser = _providerManagement!.currentUser;
  }

  //Grab the updated data from the create_group_search_bar.dart screen
  void _onDataChanged(List<User> updatedUserInGroup,
      Map<String, String> updatedUserRoles) async {
    // Print the new data before updating the state
    print('Updated User In Group: $updatedUserInGroup');
    print('Updated User Roles: $updatedUserRoles');

    List<User> users = [];
    for (var user in updatedUserInGroup) {
      user = await _providerManagement!.userService.getUserById(user.id);
      users.add(user);
    }

    // Update the state of CreateGroupData with the received data
    setState(() {
      _userUpdatedRoles = updatedUserRoles;
      _usersInGroup = users;
    });
  }

  // ** PICK IMAGE ***

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

  // ** EDIT GROUP **

  // ** Here we update or create the group's data
  void _performGroupUpdate() async {
    if (_groupName.isNotEmpty && _groupDescription.isNotEmpty) {
      bool groupCreated =
          await _updatingGroup(); // Call _creatingGroup and await the result

      if (groupCreated) {
        // Group creation was successful, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.groupEdited),
          ),
        );
      } else {
        // Group creation failed, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToEditGroup),
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

  //** REMOVE USER */

// Function to perform the removal of a user from the group

  void _performUserRemoval(String fetchedUserName, bool? invitationStatus) {
    // Check the invitation status first
    if (invitationStatus == null) {
      // User hasn't yet answered the petition
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User $fetchedUserName already has an invitation, so cannot be removed. It will expire in 5 days if not answered.'),
          duration: Duration(seconds: 5),
        ),
      );
      setState(() {});
      return;
    } else if (invitationStatus == false) {
      // User does not want to join
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User $fetchedUserName is not in the group, so cannot be removed. This user will have a maximum of 3 attempts to send a request for this group.'),
          duration: Duration(seconds: 5),
        ),
      );
      setState(() {});
      return;
    }

    // If the invitation status check passes, proceed to find and remove the user
    User? userToRemove;

    // Find the user to remove by userName
    for (var user in _usersInGroup) {
      if (user.userName.toLowerCase() == fetchedUserName.toLowerCase()) {
        userToRemove = user;
        break;
      }
    }

    // If the user is not found in the group
    if (userToRemove == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User $fetchedUserName not found in the group.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Perform the removal action
    setState(() {
      _userUpdatedRoles.remove(fetchedUserName);
      _usersInGroup.remove(userToRemove); // Remove the user from the list
    });

    _providerManagement!.groupService.removeUserInGroup(
        userToRemove.id, _group.id); // Remove user from server

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User $fetchedUserName removed from the group.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  //** HERE WE START EDITING THE GROUP WE PRESS HERE THE BUTTON */
  Future<bool> _updatingGroup() async {
    if (_groupName.trim().isEmpty) {
      // Show a SnackBar with the error message when the group name is empty or contains only whitespace characters
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.groupNameRequired),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Return false to indicate that the group creation failed.
    }

    try {
      //** EDITING THE GROUP*/
      //Now we are going to create the link of the image selected for the group
      if (_selectedImage != null) {
        _imageURL =
            await Utilities.pickAndUploadImageGroup(_group.id, _selectedImage);
      }

      // Edit the group object with the appropriate attributes
      Group updatedGroup = Group(
          id: _group.id,
          groupName: _groupName,
          ownerId: _currentUser!.id,
          userRoles: _userRolesAtFirst,
          calendar: _group.calendar,
          invitedUsers: null,
          userIds: _group.userIds,
          createdTime: DateTime.now(),
          description: _groupDescription,
          photo: _imageURL);

      //** ADD THE INVITED USERS  */
      Map<String, UserInviteStatus> invitations = {};
      //Now we proceed to create an invitation object
      _userUpdatedRoles.forEach((key, value) {
        // Check if the user's role is not "Administrator"
        if (value != 'Administrator') {
          final invitationStatus = UserInviteStatus(
            id: _group.id,
            role: '$value',
            accepted: null, // It's null because the user hasn't answered yet
          );
          invitations[key] = invitationStatus;
        }
      });

      //we update the group's invitedUsers property
      updatedGroup.invitedUsers = invitations;

      //** UPLOAD THE GROUP CREATED TO FIRESTORE */
      await _providerManagement!.updateGroup(updatedGroup);

      // Show a success message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.groupEdited)),
      );

      return true; // Return true to indicate that the group creation was successful.
    } catch (e) {
      // Handle any errors that may occur during the process.
      print("Error creating group: $e");
      return false; // Return false to indicate that the group creation failed.
    }
  }

  void _showInvitedUserDialog(BuildContext context, String userName) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // Get the user invite status for the specific user
        UserInviteStatus? userInviteStatus = _usersInvitationStatus[userName];

        return Container(
          height: 200,
          child: userInviteStatus != null
              ? ListTile(
                  title: Text(userName),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Color.fromARGB(255, 22, 151, 134),
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Role: '),
                        TextSpan(
                          text: '${userInviteStatus.role}',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.blue,
                          ),
                        ),
                        TextSpan(text: ',   '),
                        userInviteStatus.accepted != null
                            ? TextSpan(
                                text: 'Accepted: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${userInviteStatus.accepted}',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              )
                            : TextSpan(
                                text: 'Accepted: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Answer Pending',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    'No user found with the given username.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
        );
      },
    );
  }

  // ** UI FOR THE SCREEN **
  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderManagement>(
      builder: (context, providerManagement, child) {
        final TITLE_MAX_LENGTH = 25;
        final DESCRIPTION_MAX_LENGTH = 100;

        Map<String, UserInviteStatus> filteredUsers = {};

        List<MapEntry<String, UserInviteStatus>> filteredEntries =
            _usersInvitationStatus.entries.where((entry) {
          final accepted = entry.value.accepted;
          if (_showAccepted && accepted == true) {
            return true;
          } else if (_showPending && accepted == null) {
            return true;
          } else if (_showNotWantedToJoin && accepted == false) {
            return true;
          }
          return false;
        }).toList();

        filteredUsers = Map.fromEntries(filteredEntries);

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
                      radius: 50,
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
                          : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Put Group Image',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: TextEditingController(text: _groupName),
                      onChanged: (value) {
                        if (value.length <= 25) {
                          _groupName = value;
                        }
                      },
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(TITLE_MAX_LENGTH),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                                DESCRIPTION_MAX_LENGTH),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Group Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Add People to Group',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(width: 15),
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
                                          'Add People to Group',
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
                                        group: _group,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: Center(
                          child: Text('Add User'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  // Toggle Filter Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilterChip(
                        label: Text('Accepted'),
                        selected: _showAccepted,
                        onSelected: (selected) {
                          setState(() {
                            _showAccepted = selected;
                          });
                        },
                      ),
                      FilterChip(
                        label: Text('Pending'),
                        selected: _showPending,
                        onSelected: (selected) {
                          setState(() {
                            _showPending = selected;
                          });
                        },
                      ),
                      FilterChip(
                        label: Text('Not Wanted to Join'),
                        selected: _showNotWantedToJoin,
                        onSelected: (selected) {
                          setState(() {
                            _showNotWantedToJoin = selected;
                          });
                        },
                      ),
                    ],
                  ),
                  // Display Filtered Users
                  Column(
                    children: filteredUsers.entries.isNotEmpty
                        ? filteredUsers.entries.map((entry) {
                            final String username = entry.key;
                            final UserInviteStatus userInviteStatus =
                                entry.value;

                            return FutureBuilder<User?>(
                              future: _providerManagement!.userService
                                  .getUserByUsername(username),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (snapshot.hasData) {
                                  final user = snapshot.data!;
                                  final userName = user
                                      .userName; // Assuming this is how you get username from User object
                                  final roleValue =
                                      _userUpdatedRoles[userName] ??
                                          userInviteStatus.role;

                                  return Dismissible(
                                    key: Key(userName),
                                    direction:
                                        roleValue.trim() != 'Administrator'
                                            ? DismissDirection.endToStart
                                            : DismissDirection.none,
                                    // onDismissed: (direction) {
                                    //   _removeUser(context, userName);
                                    // },
                                    onDismissed: (direction) {
                                      // Show the confirmation dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirm Removal'),
                                            content: Text(
                                                'Are you sure you want to remove user $userName from the group?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  // Cancel removal, restore the user
                                                  setState(() {
                                                    // _usersInGroup.insert(indexToRemove, removedUser);
                                                  });
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  // Perform the removal action if confirmed
                                                  _performUserRemoval(
                                                      userName,
                                                      userInviteStatus
                                                          .accepted);
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                },
                                                child: Text('Confirm'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },

                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Icon(
                                        Icons.clear,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: ListTile(
                                      title: Text(userName),
                                      subtitle: Text(roleValue),
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            Utilities.buildProfileImage(
                                                user.photoUrl),
                                      ),
                                      trailing:
                                          roleValue.trim() != 'Administrator'
                                              ? GestureDetector(
                                                  onTap: () {
                                                    //TODO In the future, we can change this and add a new feature to perform to avoid duplicity
                                                    _showRoleChangeDialog(
                                                        context, userName);
                                                  },
                                                  child: Icon(
                                                    Icons.settings,
                                                    color: Colors.blue,
                                                  ),
                                                )
                                              : SizedBox.shrink(),
                                      onTap: roleValue.trim() != 'Administrator'
                                          ? () {
                                              _showRoleChangeDialog(
                                                  context, userName);
                                            }
                                          : null,
                                    ),
                                  );
                                } else {
                                  return Text('User not found');
                                }
                              },
                            );
                          }).toList()
                        : [Text("No user roles available")],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: TextButton(
                onPressed: () {
                  _performGroupUpdate();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group_add_rounded),
                    SizedBox(width: 8),
                    Text('Edit', style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRoleChangeDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedRole = _userUpdatedRoles[
            userName]; // Local variable to hold the selected role

        return AlertDialog(
          title: Text('Change Role'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: ['Co-Administrator', 'Member'].map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (String? newRole) {
                      setState(() {
                        selectedRole = newRole; // Update the local variable
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Role',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      UserInviteStatus? userInviteStatus =
                          _usersInvitationStatus[userName];
                      if (userInviteStatus != null &&
                          userInviteStatus.accepted == true) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Information'),
                              content:
                                  Text('The user is already in the group.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        Navigator.of(context).pop();
                        _showInvitedUserDialog(context, userName);
                      }
                    },
                    child: Text('Check Invitation Status'),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _userUpdatedRoles[userName] =
                      selectedRole!; // Persist the selected role to the main state
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
