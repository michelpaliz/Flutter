import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_project/enums/color_properties.dart';
import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/services/auth/logic_backend/auth_service.dart';
import 'package:first_project/services/firestore_database/logic_backend/firestore_service.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:first_project/views/group-functions/create_group_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'dart:developer' as devtools show log;

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
  late FirestoreService _storeService;
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


  void _onDataChanged(
      List<User> updatedUserInGroup, Map<String, String> updatedUserRoles) {
    // Print the new data before updating the state
    print('Updated User In Group: $updatedUserInGroup');
    print('Updated User Roles: $updatedUserRoles');

    // Update the state of CreateGroupData with the received data
    setState(() {
      _userRoles = updatedUserRoles;
      _userInGroup = updatedUserInGroup;
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
  void _updateGroupMessage() async {
    if (_groupName.isNotEmpty && _groupDescription.isNotEmpty) {
      bool groupCreated =
          await _creatingGroup_UpdatingGroup(); // Call _creatingGroup and await the result

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

    print('This is the group $_userInGroup');

    int indexToRemove = _userInGroup.indexWhere(
        (u) => u.userName.toLowerCase() == fetchedUserName.toLowerCase());

    if (indexToRemove != -1) {
      List<User> updatedUserInGroup = List.from(_userInGroup);
      updatedUserInGroup.removeAt(indexToRemove);
      setState(() {
        _userRoles.remove(fetchedUserName);
        _userInGroup.remove(updatedUserInGroup);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User $fetchedUserName removed from the group.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User $fetchedUserName not found in the group.'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  //** HERE WE START EDITING THE GROUP WE PRESS HERE THE BUTTON */
  Future<bool> _creatingGroup_UpdatingGroup() async {
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
          users: _userInGroup, // Include the list of users in the group
          createdTime: DateTime.now(),
          description: _groupDescription,
          photo: _imageURL);

      //** UPLOAD THE GROUP CREATED TO FIRESTORE */
      await _storeService.updateGroup(updateGroup);

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

    // ** UI FOR THE SCREEN ** 

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderManagement>(
      builder: (context, providerManagement, child) {
        // final storeService = Provider.of<StoreService>(context);
        // _storeService = storeService;
        final TITLE_MAX_LENGTH = 25;
        final DESCRIPTION_MAX_LENGTH = 100;
        // Initialize _storeService using data from providerManagement.
        final providerData =
            providerManagement; // Adjust this to access the necessary data.
        _storeService = FirestoreService.firebase(providerData);
        // Access the updated group from providerManagement
        // Access ProviderManagement to get updated group

        // final Group groupState = providerManagement.getUpdatedGroup(groupId);

        // Rest of your build method...
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

                    // ** ADD AN IMAGE FOR THE GROUP **
                    Text(
                      AppLocalizations.of(context)!.putGroupImage,
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 10),
                    // ** PUT YOUR GROUP'S NAME **
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
                    // ** ADD USER FOR THE GROUP ** `
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
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .close),
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
                    if (_userRoles.isNotEmpty)
                      Column(
                        children: _userRoles.keys.map((userName) {
                          final roleValue = _userRoles[userName];
                          return FutureBuilder<User?>(
                            future: _storeService.getUserByName(userName),
                            builder: (context, snapshot) {
                              devtools
                                  .log('This is username fetched $userName');
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
                                  // ** REMOVE USER **
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
                                return Text(
                                    AppLocalizations.of(context)!.userNotFound);
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
                      _updateGroupMessage();
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
                )));
      },
    );
  }
}
