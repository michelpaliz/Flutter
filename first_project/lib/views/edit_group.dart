import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/models/group.dart';
import 'package:flutter/material.dart';

import '../models/notification_user.dart';
import '../models/user.dart';
import '../services/auth/implements/auth_service.dart';
import '../services/firestore/implements/firestore_service.dart';

class EditGroup extends StatefulWidget {
  final Group group; // Add this line to accept the parameter

  const EditGroup({Key? key, required this.group})
      : super(key: key); // Modify the constructor

  @override
  State<EditGroup> createState() => _EditGroupState();
}

class _EditGroupState extends State<EditGroup> {
  StoreService storeService = new StoreService.firebase();
  AuthService authService = new AuthService.firebase();
  late TextEditingController _groupNameController;
  late List<User> _selectedUsers;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _groupNameController = TextEditingController(text: widget.group.groupName);
    _selectedUsers = List.from(widget.group.users);
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    currentUser = await authService.getCurrentUserAsCustomeModel();
    setState(() {}); // Refresh the user data and userGroups
  }

  /** By using widget.group, you're accessing the group variable that you passed to the EditGroup widget when you created it. This way, you can access the same group object that's used in the stateful widget */
  Future<void> updateRemovalUser(User user) async {
    // Remove user from the group's list
    List<User> updatedUsers =
        widget.group.users.where((u) => u.name != user.name).toList();

    // Remove the user's role from the group
    widget.group.userRoles.remove(user.id);

    setState(() {
      _selectedUsers = updatedUsers;
    });

    await storeService.removeAll(user, widget.group);

    print('User removed from group');
  }

  Future<void> _showConfirmationDialog(String action, String username) async {
    String message = action == 'add'
        ? 'Are you sure you want to add user $username?'
        : 'Are you sure you want to remove user $username?';

    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context, true);
                if (action != 'add') {
                  User userToRemove = _selectedUsers
                      .firstWhere((user) => user.name == username);
                  updateRemovalUser(userToRemove);
                }
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed) {
      if (action == 'add') {
        addUser(username);
      } else {
        User userToRemove =
            _selectedUsers.firstWhere((user) => user.name == username);
        removeUser(userToRemove);
      }
    }
  }

  Future<void> addUser(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        final user = User.fromJson(userData);

        // Set the default role to "Member" when adding a new user
        widget.group.userRoles[user.id] = "Member";

        setState(() {
          if (!_selectedUsers.contains(user)) {
            _selectedUsers.add(user);
          }
        });

        print('User added: $user');
      } else {
        // User with the provided username not found
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("User Not Found"),
              content: Text("User with the provided username was not found."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  void removeUser(User user) {
    setState(() {
      _selectedUsers.remove(user);
    });
  }

  void updateGroup(String newName, List<User> newUsers) {
    Group group = widget.group;

    // We create a notification for the new users of the group
    NotificationUser notification = NotificationUser(
      id: group.id,
      ownerId: group.ownerId,
      title: 'INVITATION TO A GROUP',
      message: 'You have received an invite to a group by ' + currentUser!.name,
      timestamp: DateTime.now(),
      hasQuestion: true,
      question: 'Would you like to join this group?',
      isAnswered: false,
    );

    // Iterate through the new users and add them to the group
    newUsers.forEach((user) {
      storeService.addUserToGroup(user, notification);
    });

    // Update the group's name and users
    setState(() {
      group.groupName = newName;
      group.users = newUsers;
    });

    storeService.updateGroup(group);

    // Perform further logic to save the changes to your data source
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Group"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(labelText: "Group Name"),
            ),
            SizedBox(height: 16),
            Text("Select Users:"),
            Expanded(
              child: ListView.builder(
                itemCount: _selectedUsers.length,
                itemBuilder: (context, index) {
                  User user = _selectedUsers[index];

                  // Get the user's current role from the group's userRoles map
                  String currentRole =
                      widget.group.userRoles[user.name] ?? "Member";

                  // Check if the user is an administrator
                  bool isAdministrator = currentRole == "Administrator";

                  return ListTile(
                    title: Text(user.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value:
                              currentRole, // Use the user's current role as the initial value
                          items: ["Administrator", "Co-Administrator", "Member"]
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: isAdministrator
                              ? null // Set onChanged to null if the user is an administrator
                              : (newValue) {
                                  setState(() {
                                    widget.group.userRoles[user.name] =
                                        newValue!;
                                  });
                                },
                          disabledHint: Text(
                              currentRole), // Show the current role as a hint
                        ),
                        SizedBox(width: 20), // Adjust the width as needed
                        if (!isAdministrator)
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              _showConfirmationDialog('remove', user.name);
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Add User"),
                      content: TextField(
                        controller: TextEditingController(),
                        decoration: InputDecoration(labelText: "Username"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            String username = TextEditingController().text;
                            _showConfirmationDialog('add', username);
                            Navigator.pop(context);
                          },
                          child: Text("Add"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text("Add User"),
            ),
            ElevatedButton(
              onPressed: () {
                String newGroupName = _groupNameController.text;
                List<User> updatedUsers = List.from(_selectedUsers);
                updateGroup(newGroupName, updatedUsers);
                Navigator.pop(context);
              },
              child: Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
