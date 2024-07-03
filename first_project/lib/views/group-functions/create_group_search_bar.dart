import 'package:first_project/models/user.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:first_project/styles/widgets/view-item-styles/costume_search_bar.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class CreateGroupSearchBar extends StatefulWidget {
  final Function(List<User> userInGroup, Map<String, String> userRoles)
      onDataChanged;
  final User? user;

// The onDataChanged callback function is invoked with updated user and role data.
  CreateGroupSearchBar({required this.onDataChanged, required this.user});
  @override
  _CreateGroupSearchBarState createState() => _CreateGroupSearchBarState();
}

// ** IN THIS SCREEN WE ONLY UPDATE THE SEARCH BAR SCREEN WE SHOULD'T ADD OR REMOVE USERS HERE TO FIRESTORE **
class _CreateGroupSearchBarState extends State<CreateGroupSearchBar> {
  List<String> searchResults = [];
  Map<String, String> userRoles = {};
  late List<String> filteredItems;
  TextEditingController _searchController = TextEditingController();
  User? _currentUser = null;
  List<User> _userInGroup = [];
  List<String> _selectedUsers = [];
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    initializeVariables();
  }

  Future<void> initializeVariables() async {
    if (widget.user != null) {
      setState(() {
        _currentUser = widget.user;
        _userInGroup = [_currentUser!];
        _selectedUsers = [_currentUser!.userName];
        userRoles[_currentUser!.userName] = 'Administrator';
      });
    }
  }

  // **SEARCH USER FUNCTIONS **

  void _searchUser(String username) async {
    try {
      // Use UserService to find users whose usernames contain the provided username
      final List<String> foundUsers =
          await userService.searchUsers(username.toLowerCase());

      // Update the search results list
      setState(() {
        searchResults = foundUsers;
      });

      // Print a message if no users are found
      if (searchResults.isEmpty) {
        print('User not found');
      }
    } catch (e) {
      print('Error searching for users: $e');
    }
  }

  void addUser(String username) async {
    try {
      // Use UserService to retrieve user data where the username matches the provided username
      final User user = await userService.getUserByUsername(username);

      // User with the provided username found
      setState(() {
        if (!_selectedUsers.contains(user.userName)) {
          _selectedUsers.add(user.userName);
          _userInGroup.add(user);
          userRoles[user.userName] =
              'Member'; // Set the default role for the new user
          widget.onDataChanged(_userInGroup, userRoles);
        }
      });

      print('User added: ${user.userName}');
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  /** Remove the user using the index of the list  */
  void removeUser(String fetchedUserName) {
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

    // Find the index of the User object in the userInGroup list that matches the username
    int indexToRemove =
        _userInGroup.indexWhere((u) => u.userName == fetchedUserName);

    if (indexToRemove != -1) {
      setState(() {
        _userInGroup.removeAt(indexToRemove);
        _selectedUsers.remove(fetchedUserName);
        widget.onDataChanged(_userInGroup, userRoles);
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
        if (_selectedUsers.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ** SHOW THE USER LIST SELECTED WITHIN THE DIALOG **
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _selectedUsers.length,
                  itemBuilder: (context, index) {
                    final selectedUser = _selectedUsers[index];
                    final userRole = userRoles[selectedUser] ?? 'Member';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 5),
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
                          if (selectedUser == _currentUser!.userName)
                            // ** Show the administrator of the group first
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              margin: EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                color: ThemeColors.getContainerBackgroundColor(
                                    context),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                child: Text(
                                  userRole,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            )
                          //** Show the other members  */
                          else
                            DropdownButton<String>(
                              value: userRole,
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(
                                  color: ThemeColors.getTextColor(context)),
                              underline: Container(
                                height: 2,
                                color: ThemeColors.getTextColor(context),
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Co-Administrator',
                                  child: Center(
                                      child: Text('Co-Administrator',
                                          style: TextStyle(fontSize: 14))),
                                ),
                                DropdownMenuItem<String>(
                                  value: 'Member',
                                  child: Center(
                                      child: Text('Member',
                                          style: TextStyle(fontSize: 14))),
                                ),
                              ],
                              //*Adding roles for the user selected **
                              onChanged: (newValue) {
                                setState(() {
                                  userRoles[selectedUser] = newValue!;
                                  widget.onDataChanged(_userInGroup, userRoles);
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
              AppLocalizations.of(context)!.userNotFound,
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
    String? _clickedUser;
    return Container(
      height: 250,
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
                      const EdgeInsets.symmetric(horizontal: 50.0, vertical: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(userName),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _clickedUser = userName;
                          });
                          addUser(userName); // Call the addUser function here
                        },
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _clickedUser =
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
