import 'dart:developer' as devtools show log;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/enums/color_properties.dart';
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

  // Function to remove a user from the group
  void _removeUser(BuildContext context, String fetchedUserName) {
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

    // Show a confirmation dialog before removing the user
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Removal'),
          content: Text(
              'Are you sure you want to remove user $fetchedUserName from the group?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform the removal action if confirmed
                _performUserRemoval(fetchedUserName);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

// Function to perform the removal of a user from the group
  void _performUserRemoval(String fetchedUserName) {
    int indexToRemove = _usersInGroup.indexWhere(
        (u) => u.userName.toLowerCase() == fetchedUserName.toLowerCase());

    if (indexToRemove != -1) {
      User removedUser =
          _usersInGroup[indexToRemove]; // Get the user to be removed

      // Perform the removal action
      setState(() {
        _userUpdatedRoles.remove(fetchedUserName);
        _usersInGroup.removeAt(indexToRemove); // Remove the user from the list
      });
      _providerManagement!.groupService.removeUserInGroup(
          removedUser.id, _group.id); // Remove user from server
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User $fetchedUserName removed from the group.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User $fetchedUserName not found in the group.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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

  //This function shows the invited users list
  void _showAllInvitedUsers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // Filter users based on the invitation status
        List<UserInviteStatus> filteredUsers = _usersInvitationStatus.values
            .where((user) => user.accepted == null || false)
            .toList();
        return Container(
          height: 300,
          child: filteredUsers.isNotEmpty
              ? ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    String userName =
                        _usersInvitationStatus.keys.elementAt(index);
                    UserInviteStatus userInviteStatus = filteredUsers[index];
                    return ListTile(
                      title: Text(userName),
                      subtitle: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(text: 'Role: '),
                            TextSpan(
                              text: '${userInviteStatus.role}',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.blue),
                            ),
                            TextSpan(text: ',   '),
                            userInviteStatus.accepted != null
                                ? TextSpan(
                                    text: 'Accepted: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '${userInviteStatus.accepted}',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  )
                                : TextSpan(
                                    text: 'Accepted: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                    );
                  },
                )
              : Center(
                  child: Text(
                    'No users found with the given status.',
                    style: TextStyle(fontSize: 14.0),
                  ),
                ),
        );
      },
    );
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

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.groupData),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  // ** SHOW GROUP'S IMAGE **
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
                    AppLocalizations.of(context)!.putGroupImage,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  // ** PUT YOUR GROUP'S NAME **
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
                        labelText: AppLocalizations.of(context)!
                            .textFieldGroupName(TITLE_MAX_LENGTH),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  // ** PUT YOUR GROUP'S DESCRIPTION **
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
                            labelText: AppLocalizations.of(context)!
                                .textFieldDescription(DESCRIPTION_MAX_LENGTH),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showAllInvitedUsers(context);
                        },
                        child: Text('Show invited users'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.addPplGroup,
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
                                          AppLocalizations.of(context)!
                                              .addPplGroup,
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
                  // ** UPDATE USER LIST **
                  Column(
                    children: _userUpdatedRoles.isNotEmpty
                        ? (() {
                            String? administratorUserName;
                            Map<String, String> otherUserRoles = {};

                            _userUpdatedRoles.forEach((key, value) {
                              if (value == 'Administrator') {
                                administratorUserName = key;
                              } else {
                                otherUserRoles[key] = value;
                              }
                            });

                            List<String> sortedOtherUserNames =
                                otherUserRoles.keys.toList()..sort();

                            List<String> sortedUserNames = [];
                            if (administratorUserName != null) {
                              sortedUserNames.add(administratorUserName!);
                            }
                            sortedUserNames.addAll(sortedOtherUserNames);

                            List<Widget> userTiles =
                                sortedUserNames.map((userName) {
                              final roleValue = _userUpdatedRoles[userName];

                              if (!userFutures.containsKey(userName)) {
                                userFutures[userName] = _providerManagement!
                                    .userService
                                    .getUserByUsername(userName);
                              }

                              return FutureBuilder<User?>(
                                future: userFutures[userName],
                                builder: (context, snapshot) {
                                  devtools.log(
                                      'This is username fetched $userName');
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    final user = snapshot.data;

                                    return ListTile(
                                      title: Text(userName),
                                      subtitle: Text(roleValue!),
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            Utilities.buildProfileImage(
                                                user?.photoUrl),
                                      ),
                                      trailing:
                                          roleValue.trim() != 'Administrator'
                                              ? GestureDetector(
                                                  onTap: () {
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
                                    );
                                  } else {
                                    return Text(AppLocalizations.of(context)!
                                        .userNotFound);
                                  }
                                },
                              );
                            }).toList();

                            return userTiles.isNotEmpty
                                ? userTiles
                                : [Text("No user roles available")];
                          })()
                        : [Text("No user roles available")],
                  )
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
                    Text(AppLocalizations.of(context)!.edit,
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ColorProperties.defaultButton(),
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
