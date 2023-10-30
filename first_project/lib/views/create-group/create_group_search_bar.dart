import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/costume_widgets/costume_search_bar.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:flutter/material.dart';

class CreateGroupSearchBar extends StatefulWidget {
  final Function(List<User> userInGroup, Map<String, String> userRoles)
      onDataChanged;

  CreateGroupSearchBar({required this.onDataChanged});
  @override
  _CreateGroupSearchBarState createState() => _CreateGroupSearchBarState();
}

class _CreateGroupSearchBarState extends State<CreateGroupSearchBar> {
  List<String> searchResults = [];
  Map<String, String> userRoles = {};
  late List<String> filteredItems;
  TextEditingController _searchController = TextEditingController();
  bool isListVisible = false;
  User? currentUser = null;
  List<User> userInGroup = [];
  List<String> selectedUsers = [];
  String? clickedUser;

  @override
  void initState() {
    super.initState();
    initializeVariables();
  }

  Future<void> initializeVariables() async {
    final fetchedUser =
        await AuthService.firebase().getCurrentUserAsCustomeModel();
    if (fetchedUser != null) {
      setState(() {
        currentUser = fetchedUser;
        userInGroup = [currentUser!];
        selectedUsers = [currentUser!.userName];
        userRoles[currentUser!.userName] = 'Administrator';
      });
    }
  }

  void _searchUser(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: username)
          .get();

      final List<String> foundUsers =
          querySnapshot.docs.map((doc) => doc['userName'] as String).toList();

      setState(() {
        searchResults = foundUsers;
      });

      if (searchResults.isEmpty) {
        print('User not found');
      }
    } catch (e) {
      print('Error searching for users: $e');
    }
  }

/** Add an user using the selectedUsers list */
  void addUser(String username) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // User with the provided username found
        final userData = querySnapshot.docs.first.data();

        final user = User.fromJson(userData);

        setState(() {
          if (!selectedUsers.contains(user.userName)) {
            selectedUsers.add(user.userName);
            userInGroup.add(user);
            userRoles[user.userName] =
                'Member'; // Set the default role for the new user
            widget.onDataChanged(userInGroup, userRoles);
          }
        });

        print('User added: ${user.userName}');
      } else {
        // User with the provided username not found
        print('User not found for username: $username');
      }
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  /** Remove the user using the index of the list  */
  void removeUser(String fetchedUserName) {
    // Check if the user is the current user before attempting to remove
    if (fetchedUserName == currentUser?.userName) {
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

    // Find the index of the User object in the userInGroup list that matches the username
    int indexToRemove =
        userInGroup.indexWhere((u) => u.userName == fetchedUserName);

    if (indexToRemove != -1) {
      setState(() {
        userInGroup.removeAt(indexToRemove);
        selectedUsers.remove(fetchedUserName);
        widget.onDataChanged(userInGroup, userRoles);
      });
      print('Remove user: $fetchedUserName');
    } else {
      print('User not found in the group: $fetchedUserName');
    }
  }

  Widget _buildSelectedUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedUsers.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedUsers.length,
                  itemBuilder: (context, index) {
                    final selectedUser = selectedUsers[index];
                    final userRole = userRoles[selectedUser] ?? 'Member';

                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedUser,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (selectedUser == currentUser!.userName)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                userRole,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            DropdownButton<String>(
                              value: userRole,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(color: Colors.black),
                              underline: Container(
                                height: 2,
                                color: Colors.black,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Administrator',
                                  child: Text('Administrator',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Co-Administrator',
                                  child: Text('Co-Administrator',
                                      style: TextStyle(fontSize: 14)),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Member',
                                  child: Text('Member',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  userRoles[selectedUser] = newValue!;
                                  widget.onDataChanged(userInGroup, userRoles);
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        else if (searchResults.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Center(
                child: Text(
                  "SEARCH RESULTS",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final searchResult = searchResults[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        searchResult,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        else
          Center(
            child: Text(
              "User not found.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: CustomSearchBar(
                controller: _searchController,
                onChanged: (value) => _searchUser(value),
                onSearch: () {}, // Provide an empty function as a placeholder
                onClear: () {
                  _searchController.clear();
                  _searchUser('');
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: searchResults.map((userName) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(userName),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            clickedUser = userName;
                          });
                          addUser(userName); // Call the addUser function here
                        },
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            clickedUser =
                                null; // Reset clickedUser when removing the userName
                          });
                          removeUser(
                              userName); // Call the removeUser function here
                        },
                        icon: Icon(Icons.remove),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            _buildSelectedUsersList()
          ],
        ),
      ),
    );
  }
}
