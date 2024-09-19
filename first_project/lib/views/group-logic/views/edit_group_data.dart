import 'dart:async';

import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/stateManagement/group_management.dart';
import 'package:first_project/stateManagement/notification_management.dart';
import 'package:first_project/stateManagement/user_management.dart';
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
import 'package:first_project/views/group-logic/group_functions/group_manager.dart';
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
    _groupName = _group.name;
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
          name: _groupName,
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
 bottomNavigationBar: BottomNavigationSection(
        onGroupUpdate: () => GroupManager.performGroupUpdate(
          context,
          groupService,
          _group,
        ), // Pass the static method with arguments
      ),

        );
      },
    );
  }
}
