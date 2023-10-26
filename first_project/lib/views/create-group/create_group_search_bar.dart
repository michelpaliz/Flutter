import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_project/costume_widgets/costume_search_bar.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:flutter/material.dart';

class CreateGroupSearchBar extends StatefulWidget {
  final String groupName;
  final String groupDescription;

  CreateGroupSearchBar({
    required this.groupName,
    required this.groupDescription,
  });

  @override
  _CreateGroupSearchBarState createState() => _CreateGroupSearchBarState();
}

class _CreateGroupSearchBarState extends State<CreateGroupSearchBar> {
  List<String> searchResults = [];
  Map<String, String> userRoles = {}; // Map to store user roles
  late List<String> filteredItems;
  TextEditingController _searchController = TextEditingController();
  bool isListVisible = false;
  User? currentUser = null;
  List<User> userInGroup = []; // List to store selected users
  List<String> selectedUsers = [];

  @override
  void initState() {
    super.initState();
    AuthService.firebase()
        .getCurrentUserAsCustomeModel()
        .then((User? fetchedUser) {
      if (fetchedUser != null) {
        setState(() {
          currentUser = fetchedUser;
          userInGroup = [currentUser!];
          selectedUsers = [currentUser!.name];
          // Set the default role to administrator for the current user
          userRoles[currentUser!.name] = 'Administrator';
        });
      }
    });
  }

 void searchUser(String username) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .get();

    final List<String> foundUsers =
        querySnapshot.docs.map((doc) => doc['name'] as String).toList();

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


  Widget _buildSelectedUsersList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (selectedUsers.isNotEmpty)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Center(
              child: Text(
                "THESE ARE THE USERS SELECTED",
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
                itemCount: selectedUsers.length,
                itemBuilder: (context, index) {
                  final selectedUser = selectedUsers[index];
                  final userRole = userRoles[selectedUser] ?? 'member';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                        if (selectedUser == currentUser!.name)
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
                                value: 'member',
                                child: Text('Member',
                                    style: TextStyle(fontSize: 14)),
                              ),
                            ],
                            onChanged: (newValue) {
                              setState(() {
                                userRoles[selectedUser] = newValue!;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Search Bar'),
      ),
      body: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            onChanged: (value) => searchUser(value),
            onSearch: () {}, // Provide an empty function as a placeholder
            onClear: () {
              _searchController.clear();
              searchUser('');
            },
          ),

          _buildSelectedUsersList()
        ],
      ),
    );
  }
}
