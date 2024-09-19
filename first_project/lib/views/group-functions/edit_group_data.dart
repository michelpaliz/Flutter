import 'dart:async';

import 'package:first_project/models/group.dart';
import 'package:first_project/models/notification_user.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:first_project/utilities/notification_formats.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:first_project/views/event-logic/edit_logic/functions/user_removal_service.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/form/bottom_nav.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/form/group_description_field.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/form/group_image_field.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/form/group_name_field.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/add_ppl_section.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/admin_info_card.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/filter_chips.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/filtered_users_list.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/invitation_functions/dismiss_user_dialog.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/invitation_functions/role_change_dialog.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/user_filter_service.dart';
import 'package:first_project/views/event-logic/edit_logic/widgets/selected_users/user_tile.dart';
import 'package:flutter/material.dart';
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

  late List<User> _usersInGroup = [];
  late Map<String, String> _usersRoles = {};
  late Map<String, UserInviteStatus> _usersInvitations = {};
  Map<String, String> _userRolesAtFirst = {};
  Map<String, UserInviteStatus> _usersInvitationAtFirst = {};

  /*!************************ */

  // late List<User> _usersInGroupAtFirst;

  bool _isNewUser = false;
  bool _addingNewUser = false;
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
  List<String> _uniqueNewKeysList = [];
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _initializeGroupData();
    _initializeUserRoles();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeGroupData() {
    // logic to initialize group data
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
    _usersRoles = _group.userRoles;
  }

  //*We init the variables for the functions
  void _initializeUserRoles() {
    if (_group.invitedUsers != null && _group.invitedUsers!.isNotEmpty) {
      // Create a deep copy of the map
      _usersInvitationAtFirst =
          Map<String, UserInviteStatus>.from(_group.invitedUsers!);

      // Create a deep copy of _usersInvitationAtFirst for _usersInvitationUpdated
      _usersInvitations = _usersInvitationAtFirst
          .map((key, value) => MapEntry(key, value.copy()));
    }

    //Select the current user role based in the group data
    if (_currentUser!.id == _group.ownerId) {
      _currentUserRoleValue = "Administrator";
    } else {
      for (var entry in _usersInvitations.entries) {
        var userName = entry.key;
        var userInvitationStatus = entry.value;

        // Check if current user ID matches the userName in the map
        if (_currentUser!.userName == userName) {
          // Do something with the userInvitationStatus
          _currentUserRoleValue = userInvitationStatus.role;
          break; // Exit the loop if the user is found
        }
      }
    }
  }

  //** Here we notify changes for the user in our group */

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Ensure that the dependencies are initialized
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);
    _notificationManagement =
        Provider.of<NotificationManagement>(context, listen: false);

    // Listen to the usersInGroupStream for changes so we can make changes for our data
    _groupManagement.usersInGroupStream.listen((users) {
      setState(() {
        _usersInGroup = users;
      });
    });

    _groupManagement.userRolesStream.listen((users) {
      setState(() {
        _userRolesAtFirst = users;
      });
    });

    // _groupManagement.usersInvitationStatus.listen((users) {
    //   setState(() {
    //     _usersInvitations = users;
    //   });
    // });
  }

  //* Here we passed the updated data but be aware this data is not uploaded in our db
  void _onDataChanged(List<User> updatedUserInGroup,
      Map<String, String> updatedUserRoles) async {
    // Print the new data before updating the state
    print('Updated User In Group: $updatedUserInGroup');
    print('Updated User Roles: $updatedUserRoles');

    // Create a map for new users invitation statuses
    Map<String, UserInviteStatus> newUsersInvitationStatus = {};

    for (var user in updatedUserInGroup) {
      newUsersInvitationStatus[user.userName] = UserInviteStatus(
        id: user.id,
        invitationAnswer: null, // Set the default or expected invitation status
        role: updatedUserRoles[user.userName] ?? 'Member',
        sendingDate: DateTime.now(),
      );
    }
    // The uniqueNewKeysList will contain the keys that are present in the newUsersInvitationStatus map but not in the _usersInvitationUpdate
    // Determine which keys are in newUsersInvitationStatus but not in _usersInvitationUpdate
    final newKeys = newUsersInvitationStatus.keys.toSet();
    final existingKeys = _usersInvitations.keys.toSet();
    final uniqueNewKeys = newKeys.difference(existingKeys);

    // Convert the set of unique new keys to a list
    _uniqueNewKeysList = uniqueNewKeys.toList();

    setState(() {
      _usersRoles = updatedUserRoles;
      _usersInGroup = updatedUserInGroup;
      _usersInvitations =
          newUsersInvitationStatus; // Update the invitation status

      // Print the unique keys list for debugging purposes
      print('Unique new keys: $_uniqueNewKeysList');
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

      //We update the map in case the admin has edited any members data
      if (_usersInvitations != _usersInvitationAtFirst) {
        _usersInvitations = _usersInvitationAtFirst;
      }

      // Edit the group object with the appropriate attributes
      Group updatedGroup = Group(
          id: _group.id,
          groupName: _groupName,
          ownerId: _currentUser!.id,
          userRoles: _userRolesAtFirst,
          calendar: _group.calendar,
          invitedUsers: _usersInvitations,
          userIds: _group.userIds,
          createdTime: DateTime.now(),
          description: _groupDescription,
          photo: _imageURL);

      //** ADD THE INVITED USERS  */
      Map<String, UserInviteStatus> invitations = {};

      if (_addingNewUser) {
        //Now we proceed to create an invitation object
        _usersRoles.forEach((key, value) {
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
      }

      //we update the group's invitedUsers property
      // updatedGroup.invitedUsers = invitations;

      print('Updated Group: ${updatedGroup.toString()}');

      //** UPLOAD THE GROUP CREATED TO OUR DB*/
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

  //** REMOVE USER */

// Function to perform the removal of a user from the group

  void _performUserRemoval(String fetchedUserName, bool? invitationStatus) {
    // Fetch the user based on userName
    final fetchedUser = _usersInGroup.firstWhere(
        (user) => user.userName.toLowerCase() == fetchedUserName.toLowerCase());

    if (_isNewUser) {
      _handleNewUserRemoval(fetchedUser.userName);
    } else {
      _handleExistingUserRemoval(fetchedUser, invitationStatus);
    }
  }

  void _handleNewUserRemoval(String fetchedUserName) {
    setState(() {
      _usersInGroup.removeWhere(
        (user) => user.userName.toLowerCase() == fetchedUserName.toLowerCase(),
      );
      _usersInvitations.remove(fetchedUserName);
      _usersRoles.remove(fetchedUserName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'User $fetchedUserName removed before sending any invitation.'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  // Function to handle the removal of an existing user who was already in the group
  Future<void> _handleExistingUserRemoval(
      User fetchedUser, bool? invitationStatus) async {
    // If the user is already in the group, remove them from both the group and the invite record
    if (_usersInGroup.any((user) =>
        user.userName.toLowerCase() == fetchedUser.userName.toLowerCase())) {
      setState(() {
        _usersRoles.remove(fetchedUser.userName);
        _usersInGroup.removeWhere((user) =>
            user.userName.toLowerCase() == fetchedUser.userName.toLowerCase());
        _usersInvitations
            .remove(fetchedUser.userName); // Remove the invite record as well
      });

      // Remove user from server
      bool result = await _groupManagement.groupService.removeUserInGroup(
        fetchedUser
            .id, // Use the actual user ID or username as needed by the service
        _group.id,
      );

      if (result) {
        User admin =
            await _userManagement!.userService.getUserById(fetchedUser.id);

        NotificationFormats notificationFormats = new NotificationFormats();

        NotificationUser ntfAdmin = notificationFormats.userRemovedFromGroup(
            _group, fetchedUser, admin);

        NotificationUser ntfMember =
            notificationFormats.notifyUserRemoval(_group, fetchedUser, admin);

        await _notificationManagement.addNotificationToDB(
            ntfAdmin, _userManagement!);

        await _notificationManagement.addNotificationToDB(
            ntfMember, _userManagement!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'User ${fetchedUser.userName} removed from the group and their invitation record has been deleted.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } else if (invitationStatus == null) {
      // Handle users with pending invites
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User $fetchedUser.userName has a pending invitation and cannot be removed until the invitation is answered.'),
          duration: Duration(seconds: 5),
        ),
      );
    } else if (invitationStatus == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'User ${fetchedUser.userName} declined the invitation, but the invitation record is retained.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserManagement>(
      builder: (context, providerManagement, child) {
        final filteredUsers = UserFilterService.filterUsers(
          _currentUserRoleValue,
          _currentUser,
          _usersInvitations,
          _showAccepted,
          _showPending,
          _showNotWantedToJoin,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('Group Data'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  GroupImageSection(
                    imageURL: _imageURL,
                    selectedImage: _selectedImage,
                    onPickImage: _pickImage,
                  ),
                  SizedBox(height: 10),
                  GroupNameField(
                    groupName: _groupName,
                    onNameChange: (value) {
                      if (value.length <= 25) {
                        _groupName = value;
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  GroupDescriptionField(
                    descriptionController: _descriptionController,
                  ),
                  SizedBox(height: 10),
                  if (_currentUserRoleValue == "Administrator")
                    AdminInfoCard(
                      currentUser: _currentUser!,
                    ),
                  SizedBox(height: 10),
                  AddPeopleSection(
                    currentUser: _currentUser,
                    group: _group,
                    onDataChanged: _onDataChanged,
                  ),
                  SizedBox(height: 10),
                  FilterChipsSection(
                    showAccepted: _showAccepted,
                    showPending: _showPending,
                    showNotWantedToJoin: _showNotWantedToJoin,
                    onFilterChange: (String filter, bool isSelected) {
                      setState(() {
                        switch (filter) {
                          case 'Accepted':
                            _showAccepted = isSelected;
                            break;
                          case 'Pending':
                            _showPending = isSelected;
                            break;
                          case 'NotAccepted':
                            _showNotWantedToJoin = isSelected;
                            break;
                        }
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  UserList(
                    filteredUsers: filteredUsers,
                    usersRoles: _usersRoles,
                    userManagement: _userManagement!,
                    buildUserTile: (userName, user, roleValue) {
                      String? selectedRole =
                          _usersRoles[userName]; // Get the user's role
                      UserInviteStatus? userInviteStatus = _usersInvitations[
                          userName]; // Get the user's invitation status

                      return UserTile(
                        userName: userName,
                        user: user,
                        roleValue: roleValue,
                        onChangeRole: (name) {
                          RoleChangeDialog.show(
                            context,
                            userName,
                            selectedRole,
                            userInviteStatus,
                            (newRole) => setState(() {
                              // Handle role selection
                              _usersRoles[userName] = newRole!;
                            }),
                            _usersRoles,
                            _usersInvitations,
                            _usersInvitationAtFirst,
                          );
                        },
                        onDismissed: (String userName) {
                          // Show the DismissUserDialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DismissUserDialog(
                                userName: userName,
                                isNewUser: _usersInvitationAtFirst
                                    .containsKey(userName),
                                onCancel: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                                onConfirm: () async {
                                  final userRemovalService = UserRemovalService(
                                    context: context,
                                    usersInGroup: _usersInGroup,
                                    usersInvitations: _usersInvitations,
                                    usersRoles: _usersRoles,
                                    groupManagement: _groupManagement,
                                    userManagement: _userManagement!,
                                    group: _group,
                                    notificationManagement:
                                        _notificationManagement,
                                  );

                                  // Convert the invitation status (String to bool?)
                                  bool? invitationStatus;
                                  switch (_usersInvitations[userName]?.status) {
                                    case 'accepted':
                                      invitationStatus = true;
                                      break;
                                    case 'declined':
                                      invitationStatus = false;
                                      break;
                                    case 'pending':
                                      invitationStatus = null;
                                      break;
                                  }

                                  // Perform the user removal using the service and await the result
                                  bool success = await userRemovalService
                                      .performUserRemoval(
                                    userName,
                                    invitationStatus,
                                    _usersInvitationAtFirst
                                        .containsKey(userName),
                                  );

                                  // Notify user based on success or failure
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'User $userName removed successfully.'),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to remove user $userName.'),
                                        duration: Duration(seconds: 5),
                                      ),
                                    );
                                  }

                                  // Close the dialog after confirmation
                                  Navigator.of(context).pop();
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar:
              BottomNavigationSection(onGroupUpdate: _performGroupUpdate),
        );
      },
    );
  }

  // // ** UI FOR THE SCREEN **
  // @override
  // Widget build(BuildContext context) {
  //   return Consumer<UserManagement>(
  //     builder: (context, providerManagement, child) {
  //       final filteredUsers = _filterUsers();

  //       return Scaffold(
  //         appBar: AppBar(
  //           title: Text('Group Data'),
  //         ),
  //         body: SingleChildScrollView(
  //           child: Padding(
  //             padding: const EdgeInsets.all(15.0),
  //             child: Column(
  //               children: [
  //                 _buildGroupImageSection(),
  //                 SizedBox(height: 10),
  //                 _buildGroupNameField(),
  //                 SizedBox(height: 10),
  //                 _buildGroupDescriptionField(),
  //                 SizedBox(height: 10),
  //                 if (_currentUserRoleValue == "Administrator")
  //                   _buildAdminInfoCard(),
  //                 SizedBox(height: 10),
  //                 _buildAddPeopleSection(context),
  //                 SizedBox(height: 10),
  //                 _buildFilterChips(),
  //                 SizedBox(height: 10),
  //                 _buildFilteredUsersList(filteredUsers),
  //               ],
  //             ),
  //           ),
  //         ),
  //         bottomNavigationBar: _buildBottomNavigation(),
  //       );
  //     },
  //   );
  // }

  // Map<String, UserInviteStatus> _filterUsers() {
  //   final adminUserName = _currentUserRoleValue == "Administrator"
  //       ? _currentUser!.userName
  //       : null;

  //   final filteredEntries = _usersInvitations.entries.where((entry) {
  //     final username = entry.key;
  //     final accepted = entry.value.invitationAnswer;

  //     if (username == adminUserName) return false;
  //     if (_showAccepted && accepted == true) return true;
  //     if (_showPending && accepted == null) return true;
  //     if (_showNotWantedToJoin && accepted == false) return true;
  //     return false;
  //   }).toList();

  //   return Map.fromEntries(filteredEntries);
  // }

  // Widget _buildGroupImageSection() {
  //   return GestureDetector(
  //     onTap: _pickImage,
  //     child: CircleAvatar(
  //       radius: 50,
  //       backgroundColor: _selectedImage != null ? Colors.transparent : null,
  //       backgroundImage: _imageURL.isNotEmpty
  //           ? CachedNetworkImageProvider(_imageURL) as ImageProvider<Object>?
  //           : _selectedImage != null
  //               ? FileImage(File(_selectedImage!.path))
  //               : null,
  //       child: _imageURL.isEmpty && _selectedImage == null
  //           ? Icon(Icons.add_a_photo, size: 50, color: Colors.white)
  //           : null,
  //     ),
  //   );
  // }

  // Widget _buildGroupNameField() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: TextField(
  //       controller: TextEditingController(text: _groupName),
  //       onChanged: (value) {
  //         if (value.length <= 25) {
  //           _groupName = value;
  //         }
  //       },
  //       inputFormatters: [LengthLimitingTextInputFormatter(25)],
  //       decoration: InputDecoration(
  //         labelText: 'Group Name',
  //         border: OutlineInputBorder(),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildGroupDescriptionField() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: TextField(
  //       controller: _descriptionController,
  //       maxLines: 5,
  //       inputFormatters: [LengthLimitingTextInputFormatter(100)],
  //       decoration: InputDecoration(
  //         labelText: 'Group Description',
  //         border: OutlineInputBorder(),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildAdminInfoCard() {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Card(
  //       elevation: 5,
  //       child: ListTile(
  //         title: Text('Admin: ${_currentUser!.userName}'),
  //         subtitle: Text('Role: Administrator'),
  //         leading: CircleAvatar(
  //           backgroundImage:
  //               Utilities.buildProfileImage(_currentUser!.photoUrl),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildAddPeopleSection(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text('Add People to Group', style: TextStyle(color: Colors.grey)),
  //       SizedBox(width: 15),
  //       TextButton(
  //         onPressed: () {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return Dialog(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Padding(
  //                       padding: const EdgeInsets.all(16.0),
  //                       child: Center(
  //                         child: Text(
  //                           'Add People to Group',
  //                           style: TextStyle(
  //                             fontFamily: 'Lato',
  //                             fontSize: 15,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Padding(
  //                       padding: const EdgeInsets.all(10.0),
  //                       child: CreateGroupSearchBar(
  //                         onDataChanged: _onDataChanged,
  //                         user: _currentUser,
  //                         group: _group,
  //                       ),
  //                     ),
  //                     TextButton(
  //                       onPressed: () {
  //                         Navigator.of(context).pop();
  //                       },
  //                       child: Text('Close'),
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           );
  //         },
  //         child: Center(child: Text('Add User')),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildFilterChips() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       FilterChip(
  //         label: Text('Accepted'),
  //         selected: _showAccepted,
  //         onSelected: (selected) {
  //           setState(() {
  //             _showAccepted = selected;
  //           });
  //         },
  //       ),
  //       FilterChip(
  //         label: Text('Pending'),
  //         selected: _showPending,
  //         onSelected: (selected) {
  //           setState(() {
  //             _showPending = selected;
  //           });
  //         },
  //       ),
  //       FilterChip(
  //         label: Text('Not Accepted'),
  //         selected: _showNotWantedToJoin,
  //         onSelected: (selected) {
  //           setState(() {
  //             _showNotWantedToJoin = selected;
  //           });
  //         },
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildBottomNavigation() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: TextButton(
  //       onPressed: _performGroupUpdate,
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(Icons.group_add_rounded),
  //           SizedBox(width: 8),
  //           Text('Edit', style: TextStyle(color: Colors.white)),
  //         ],
  //       ),
  //       style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
  //     ),
  //   );
  // }

  // Widget _buildFilteredUsersList(Map<String, UserInviteStatus> filteredUsers) {
  //   return Column(
  //     children: filteredUsers.entries.isNotEmpty
  //         ? filteredUsers.entries.map((entry) {
  //             final String userName = entry.key;
  //             final UserInviteStatus userInviteStatus = entry.value;

  //             return FutureBuilder<User?>(
  //               future:
  //                   _userManagement!.userService.getUserByUsername(userName),
  //               builder: (context, snapshot) {
  //                 if (snapshot.connectionState == ConnectionState.waiting) {
  //                   return CircularProgressIndicator();
  //                 } else if (snapshot.hasError) {
  //                   return Text('Error: ${snapshot.error}');
  //                 } else if (snapshot.hasData) {
  //                   final user = snapshot.data!;
  //                   final roleValue =
  //                       _usersRoles[userName] ?? userInviteStatus.role;

  //                   return _buildUserTile(userName, user, roleValue);
  //                 } else {
  //                   return Text('User not found');
  //                 }
  //               },
  //             );
  //           }).toList()
  //         : [Text("No user roles available")],
  //   );
  // }

  // void _handleDismissedUser(String userName) {
  //   setState(() {
  //     _isDismissed = true; // Mark the item as dismissed
  //   });

  //   // Show a confirmation dialog
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // Check if the user is newly added
  //       _isNewUser = _uniqueNewKeysList.contains(userName.toLowerCase());

  //       return AlertDialog(
  //         title: Text(_isNewUser ? 'Confirm Removal' : 'Confirm Action'),
  //         content: Text(
  //           _isNewUser
  //               ? 'You just added this user. Would you like to remove them from the invitation list?'
  //               : 'Are you sure you want to remove user $userName from the group?',
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 _isDismissed = false; // Cancel the dismissal
  //               });
  //               Navigator.of(context).pop(); // Close the dialog

  //               // Optionally show a snack bar
  //               final scaffold = ScaffoldMessenger.of(context);
  //               scaffold.showSnackBar(
  //                 SnackBar(
  //                   content: Text('Removal action canceled.'),
  //                   duration: Duration(seconds: 2),
  //                 ),
  //               );
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog

  //               // Perform the actual removal of the user
  //               _performUserRemoval(
  //                   userName, _usersInvitations[userName]?.invitationAnswer);

  //               setState(() {
  //                 _isDismissed = false; // Reset the dismissed flag
  //               });
  //             },
  //             child: Text('Confirm'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget _buildUserTile(String userName, User user, String roleValue) {
  //   return Dismissible(
  //     key: Key(userName),
  //     direction: roleValue.trim() != 'Administrator'
  //         ? DismissDirection.endToStart
  //         : DismissDirection.none,
  //     onDismissed: (direction) {
  //       _handleDismissedUser(userName);
  //     },
  //     background: Container(
  //       color: Colors.red,
  //       alignment: Alignment.centerRight,
  //       padding: EdgeInsets.symmetric(horizontal: 20),
  //       child: Icon(Icons.delete, color: Colors.white),
  //     ),
  //     child: ListTile(
  //       title: Text(userName),
  //       subtitle: Text(roleValue),
  //       leading: CircleAvatar(
  //         radius: 30,
  //         backgroundImage: Utilities.buildProfileImage(user.photoUrl),
  //       ),
  //       trailing: roleValue.trim() != 'Administrator'
  //           ? GestureDetector(
  //               onTap: () {
  //                 _showRoleChangeDialog(context, userName);
  //               },
  //               child: Icon(Icons.settings, color: Colors.blue),
  //             )
  //           : SizedBox.shrink(),
  //       onTap: roleValue.trim() != 'Administrator'
  //           ? () {
  //               _showRoleChangeDialog(context, userName);
  //             }
  //           : null,
  //     ),
  //   );
  // }

  // void _showRoleChangeDialog(BuildContext context, String userName) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       String? selectedRole = _usersRoles[userName];
  //       UserInviteStatus? userInviteStatus = _usersInvitations[userName];
  //       String informativeMessage = _getInvitationMessage(userInviteStatus);
  //       bool showRoleDropdown = _shouldShowRoleDropdown(userInviteStatus);
  //       String additionalMessage = _getAdditionalMessage(userInviteStatus);

  //       return _buildRoleChangeDialog(
  //         context,
  //         userName,
  //         selectedRole,
  //         informativeMessage,
  //         additionalMessage,
  //         showRoleDropdown,
  //         userInviteStatus,
  //       );
  //     },
  //   );
  // }

  // String _getInvitationMessage(UserInviteStatus? userInviteStatus) {
  //   if (userInviteStatus == null) {
  //     return 'No invitation record found for this user.';
  //   }

  //   if (userInviteStatus.invitationAnswer == null) {
  //     return 'The invitation is pending. No action is required yet.';
  //   } else if (userInviteStatus.invitationAnswer == false) {
  //     if (userInviteStatus.attempts == 1) {
  //       return 'The user declined the invitation. You can resend the invitation after 2 weeks.';
  //     } else if (userInviteStatus.attempts == 2) {
  //       return 'The user declined the invitation again. You can resend the invitation after 1 month.';
  //     } else if (userInviteStatus.attempts >= 3) {
  //       return 'The user has declined the invitation three times. No more attempts are allowed.';
  //     }
  //   } else if (userInviteStatus.invitationAnswer == true) {
  //     return 'The user accepted the invitation and is already in the group.';
  //   }

  //   return 'Unknown invitation status.';
  // }

  // bool _shouldShowRoleDropdown(UserInviteStatus? userInviteStatus) {
  //   if (userInviteStatus == null) return false;

  //   final int daysSinceSent =
  //       DateTime.now().difference(userInviteStatus.sendingDate).inDays;

  //   if (userInviteStatus.invitationAnswer == false) {
  //     if (userInviteStatus.attempts == 1 && daysSinceSent >= 2) {
  //       return true;
  //     } else if (userInviteStatus.attempts == 2 && daysSinceSent >= 30) {
  //       return true;
  //     }
  //   } else if (userInviteStatus.invitationAnswer == true) {
  //     return true;
  //   }
  //   return false;
  // }

  // String _getAdditionalMessage(UserInviteStatus? userInviteStatus) {
  //   if (userInviteStatus == null) return '';

  //   final int daysSinceSent =
  //       DateTime.now().difference(userInviteStatus.sendingDate).inDays;

  //   if (userInviteStatus.invitationAnswer == false) {
  //     if (userInviteStatus.attempts == 1 && daysSinceSent >= 2) {
  //       return 'Time has passed. You can now change the role and resend the invitation.';
  //     } else if (userInviteStatus.attempts == 2 && daysSinceSent >= 30) {
  //       return 'Time has passed. You can now change the role and resend the invitation.';
  //     }
  //   }
  //   return '';
  // }

  // //** CHANGE ROLES FOR THE USERS

  // Widget _buildRoleChangeDialog(
  //   BuildContext context,
  //   String userName,
  //   String? selectedRole,
  //   String informativeMessage,
  //   String additionalMessage,
  //   bool showRoleDropdown,
  //   UserInviteStatus? userInviteStatus,
  // ) {
  //   return AlertDialog(
  //     title: Text('Change Role for $userName'),
  //     content: StatefulBuilder(
  //       builder: (BuildContext context, StateSetter setState) {
  //         return Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             if (userInviteStatus != null)
  //               _buildInvitationStatusTile(
  //                   informativeMessage, additionalMessage, userInviteStatus),
  //             SizedBox(height: 20),
  //             if (showRoleDropdown) _buildRoleDropdown(selectedRole, setState),
  //           ],
  //         );
  //       },
  //     ),
  //     actions: _buildDialogActions(
  //         context, userName, selectedRole, showRoleDropdown, additionalMessage),
  //   );
  // }

  // ListTile _buildInvitationStatusTile(
  //   String informativeMessage,
  //   String additionalMessage,
  //   UserInviteStatus userInviteStatus,
  // ) {
  //   return ListTile(
  //     title: RichText(
  //       text: TextSpan(
  //         style: TextStyle(color: Colors.black),
  //         children: [
  //           TextSpan(
  //             text: "Invitation Status: ",
  //             style: TextStyle(
  //               fontWeight: FontWeight.bold,
  //               color: Color.fromARGB(255, 22, 151, 134),
  //             ),
  //           ),
  //           TextSpan(
  //             text: '${userInviteStatus.status}',
  //             style: TextStyle(color: Colors.blue),
  //           ),
  //         ],
  //       ),
  //     ),
  //     subtitle: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(height: 8.0),
  //         Text(
  //           informativeMessage,
  //           style: TextStyle(fontSize: 14.0, color: Colors.black87),
  //         ),
  //         if (additionalMessage.isNotEmpty) ...[
  //           SizedBox(height: 10.0),
  //           Text(
  //             additionalMessage,
  //             style: TextStyle(
  //               fontSize: 14.0,
  //               color: Colors.black87,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  // DropdownButtonFormField<String> _buildRoleDropdown(
  //   String? selectedRole,
  //   StateSetter setState,
  // ) {
  //   return DropdownButtonFormField<String>(
  //     value: selectedRole,
  //     items: ['Co-Administrator', 'Member'].map((String role) {
  //       return DropdownMenuItem<String>(
  //         value: role,
  //         child: Text(role),
  //       );
  //     }).toList(),
  //     onChanged: (String? newRole) {
  //       setState(() {
  //         selectedRole = newRole;
  //       });
  //     },
  //     decoration: InputDecoration(
  //       labelText: 'Select Role',
  //       contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
  //       border: OutlineInputBorder(),
  //     ),
  //   );
  // }

  // List<Widget> _buildDialogActions(
  //   BuildContext context,
  //   String userName,
  //   String? selectedRole,
  //   bool showRoleDropdown,
  //   String additionalMessage,
  // ) {
  //   return [
  //     TextButton(
  //       onPressed: () {
  //         if (showRoleDropdown && additionalMessage.isNotEmpty) {
  //           _updateStatus(userName);
  //         }
  //         setState(() {
  //           _usersRoles[userName] = selectedRole!;
  //         });
  //         Navigator.of(context).pop();
  //       },
  //       child: Text('OK'),
  //     ),
  //     TextButton(
  //       onPressed: () {
  //         Navigator.of(context).pop();
  //       },
  //       child: Text('Cancel'),
  //     ),
  //   ];
  // }

  // void _updateStatus(String userName) {
  //   if (_usersInvitations.containsKey(userName)) {
  //     // Create a copy of the original UserInviteStatus object
  //     UserInviteStatus originalStatus = _usersInvitations[userName]!;
  //     UserInviteStatus updatedStatus = UserInviteStatus(
  //       id: originalStatus.id,
  //       role: originalStatus.role,
  //       attempts: originalStatus.attempts + 1,
  //       sendingDate: DateTime.now(),
  //       invitationAnswer: null, // Reset to pending
  //     );

  //     // Now update your secondary map or state with the modified copy
  //     _usersInvitationAtFirst[userName] = updatedStatus;

  //     // Optionally, you can also update the main map if needed only after certain conditions are met
  //     // _usersInvitationAtFirst[userName] = updatedStatus;
  //   }
  // }
}
