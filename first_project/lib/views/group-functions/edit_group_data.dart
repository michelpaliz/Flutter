import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
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
  Map<String, UserInviteStatus> _usersInvitationAtFirst = {};
  late List<User> _usersInGroupForUpdate = [];
  late List<User> _usersInGroupAtFirst;
  bool _isDismissed = false; // Track if the item is dismissed
  late final Group _group;
  String _imageURL = "";
  Map<String, Future<User?>> userFutures =
      {}; //Needs to be outside the build (ui state) to avoid loading
  late UserManagement? _userManagement;
  late GroupManagement _groupManagement;
  late NotificationManagement _notificationManagement;
  bool _showAccepted = true;
  bool _showPending = true;
  bool _showNotWantedToJoin = true;
  late String _currentUserRoleValue;
  // Update _usersInvitationStatus with new users
  Map<String, UserInviteStatus> newUsersInvitationStatus = {};

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
    _usersInGroupForUpdate = widget.users;
    _usersInGroupAtFirst = widget.users;
    if (_group.invitedUsers != null && _group.invitedUsers!.isNotEmpty) {
      _usersInvitationAtFirst = _group.invitedUsers!;
    }

    if (_currentUser!.id == _group.ownerId) {
      _currentUserRoleValue = "Administrator";
    } else {
      for (var entry in _usersInvitationAtFirst.entries) {
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
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
    _notificationManagement =
        Provider.of<NotificationManagement>(context, listen: false);
    _currentUser = _userManagement!.currentUser;
  }

  void _onDataChanged(List<User> updatedUserInGroup,
      Map<String, String> updatedUserRoles) async {
    // Print the new data before updating the state
    print('Updated User In Group: $updatedUserInGroup');
    print('Updated User Roles: $updatedUserRoles');

    for (var user in updatedUserInGroup) {
      newUsersInvitationStatus[user.userName] = UserInviteStatus(
        id: user.id,
        invitationAnswer: null, // Set the default or expected invitation status
        role: updatedUserRoles[user.userName] ?? 'Member',
        sendingDate: DateTime.now(), // Assuming 'Member' is the default role
      );
    }

    setState(() {
      _userUpdatedRoles = updatedUserRoles;
      _usersInGroupForUpdate = updatedUserInGroup;
      // Merge new users into the existing _usersInvitationStatus
      _usersInvitationAtFirst.addAll(newUsersInvitationStatus);
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
    // Check if the user is newly added (not in the initial list of users)
    final isNewUser = !_usersInGroupAtFirst.any(
      (user) => user.userName.toLowerCase() == fetchedUserName.toLowerCase(),
    );

    if (isNewUser) {
      _handleNewUserRemoval(fetchedUserName);
    } else {
      _handleExistingUserRemoval(fetchedUserName, invitationStatus);
    }
  }

  void _handleNewUserRemoval(String fetchedUserName) {
    setState(() {
      _usersInGroupForUpdate.removeWhere(
        (user) => user.userName.toLowerCase() == fetchedUserName.toLowerCase(),
      );
      _usersInvitationAtFirst.remove(fetchedUserName);
      _userUpdatedRoles.remove(fetchedUserName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'User $fetchedUserName removed before sending any invitation.'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _handleExistingUserRemoval(
      String fetchedUserName, bool? invitationStatus) {
    // Check invitation status
    if (invitationStatus == null) {
      // User hasn't yet answered the invitation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User $fetchedUserName already has an invitation, so cannot be removed. It will expire in 5 days if not answered.',
          ),
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
            'User $fetchedUserName has declined the invitation and is not in the group. This user will have a maximum of 3 attempts to send a request for this group.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
      setState(() {});
      return;
    }

    // Find the user to remove by userName
    User? userToRemove;
    for (var user in _usersInGroupForUpdate) {
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
      _usersInGroupForUpdate
          .remove(userToRemove); // Remove the user from the list
    });

    _groupManagement.groupService.removeUserInGroup(
      userToRemove.id,
      _group.id,
    ); // Remove user from server

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
          invitedUsers: _usersInvitationAtFirst,
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
              invitationAnswer:
                  null, // It's null because the user hasn't answered yet
              sendingDate: DateTime.now());
          invitations[key] = invitationStatus;
        }
      });

      //we update the group's invitedUsers property
      updatedGroup.invitedUsers = invitations;

      print('Updated Group: ${updatedGroup.toString()}');

      //** UPLOAD THE GROUP CREATED TO FIRESTORE */
      await _groupManagement.updateGroup(
          updatedGroup, _userManagement!, _notificationManagement, invitations);

      // Show a success message using a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.groupEdited)),
      );

      Navigator.pop(context);

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
        UserInviteStatus? userInviteStatus = _usersInvitationAtFirst[userName];

        return Container(
          height: 150,
          padding: EdgeInsets.all(16.0),
          child: userInviteStatus != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Information", // Title
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Colors.black, // Set the title color
                      ),
                    ),
                    SizedBox(height: 8.0), // Space between title and user name
                    ListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "User name: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 22, 151,
                                    134), // Set the color to black
                              ),
                            ),
                            TextSpan(
                              text: userName,
                              style: TextStyle(
                                color: Colors.blue,
                                // Set the desired color
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.0), // Space between lines
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color.fromARGB(255, 22, 151, 134),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Role: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )),
                                TextSpan(
                                  text: '${userInviteStatus.role}',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.0), // Space between lines
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color.fromARGB(255, 22, 151, 134),
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Accepted: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                userInviteStatus.invitationAnswer != null
                                    ? TextSpan(
                                        text:
                                            '${userInviteStatus.invitationAnswer}',
                                        style: TextStyle(color: Colors.blue),
                                        children: [
                                          // Check if the answer is "Answer Pending" or "Not Accepted"
                                          if (userInviteStatus
                                                      .invitationAnswer ==
                                                  'Answer Pending' ||
                                              userInviteStatus
                                                      .invitationAnswer ==
                                                  'Not Accepted')
                                            TextSpan(
                                              text:
                                                  ' (Attempts: ${userInviteStatus.attempts}/3)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                color: Colors.red,
                                              ),
                                            ),
                                        ],
                                      )
                                    : TextSpan(
                                        text: 'Answer Pending',
                                        style: TextStyle(color: Colors.blue),
                                        children: [
                                          // Show the number of attempts if the answer is pending
                                          TextSpan(
                                            text:
                                                ' (Attempts: ${userInviteStatus.attempts}/3)',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    return Consumer<UserManagement>(
      builder: (context, providerManagement, child) {
        final TITLE_MAX_LENGTH = 25;
        final DESCRIPTION_MAX_LENGTH = 100;

        // Filter out the admin user from the _usersInvitationStatus map
        final adminUserName = _currentUserRoleValue == "Administrator"
            ? _currentUser!.userName
            : null;
        final filteredEntries = _usersInvitationAtFirst.entries.where((entry) {
          final username = entry.key;
          final accepted = entry.value.invitationAnswer;

          // Skip the admin user
          if (username == adminUserName) {
            return false;
          }

          if (_showAccepted && accepted == true) {
            return true;
          } else if (_showPending && accepted == null) {
            return true;
          } else if (_showNotWantedToJoin && accepted == false) {
            return true;
          }
          return false;
        }).toList();

        final filteredUsers = Map.fromEntries(filteredEntries);

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

                  // Display Admin Information
                  if (_currentUserRoleValue == "Administrator")
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5,
                        child: ListTile(
                          title: Text('Admin: ${_currentUser!.userName}'),
                          subtitle: Text('Role: Administrator'),
                          leading: CircleAvatar(
                            backgroundImage: Utilities.buildProfileImage(
                                _currentUser!.photoUrl),
                          ),
                        ),
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
                  SizedBox(height: 10),

                  // Display Filtered Users
                  Column(
                    children: filteredUsers.entries.isNotEmpty
                        ? filteredUsers.entries.map((entry) {
                            final String username = entry.key;
                            final UserInviteStatus userInviteStatus =
                                entry.value;

                            return FutureBuilder<User?>(
                              future: _userManagement!.userService
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
                                    onDismissed: (direction) {
                                      setState(() {
                                        _isDismissed = true;
                                      });

                                      // Show the confirmation dialog
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          final isNewUser =
                                              !_usersInGroupAtFirst.any(
                                            (user) =>
                                                user.userName.toLowerCase() ==
                                                userName.toLowerCase(),
                                          );

                                          return AlertDialog(
                                            title: Text(isNewUser
                                                ? 'Confirm Removal'
                                                : 'Confirm Action'),
                                            content: Text(
                                              isNewUser
                                                  ? 'You just added this user. Would you like to remove them from the invitation list?'
                                                  : 'Are you sure you want to remove user $userName from the group?',
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _isDismissed = false;
                                                  });
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                  // Revert the swipe
                                                  final scaffold =
                                                      ScaffoldMessenger.of(
                                                          context);
                                                  scaffold.showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Removal action canceled.'),
                                                      duration:
                                                          Duration(seconds: 2),
                                                    ),
                                                  );
                                                },
                                                child: Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(); // Close the dialog
                                                  _performUserRemoval(
                                                      userName,
                                                      userInviteStatus
                                                          .invitationAnswer);
                                                  setState(() {
                                                    _isDismissed = false;
                                                  });
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
                                        Icons.delete,
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
                          _usersInvitationAtFirst[userName];
                      if (userInviteStatus != null &&
                          userInviteStatus.invitationAnswer == true) {
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
