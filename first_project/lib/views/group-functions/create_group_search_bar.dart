import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/user_management.dart';
import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:first_project/styles/widgets/view-item-styles/costume_search_bar.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:provider/provider.dart';

class CreateGroupSearchBar extends StatefulWidget {
  final Function(List<User> usersInGroup, Map<String, String> userRoles)
      onDataChanged;
  final User? user;
  final Group? group;

  CreateGroupSearchBar({
    required this.onDataChanged,
    required this.user,
    required this.group,
  });

  @override
  _CreateGroupSearchBarState createState() => _CreateGroupSearchBarState();
}

class _CreateGroupSearchBarState extends State<CreateGroupSearchBar> {
  List<String> searchResults = [];
  Map<String, String> _userRoles = {};
  TextEditingController _searchController = TextEditingController();
  User? _currentUser;
  Group? _group;
  List<User> _usersAlreadyInGroup = [];
  Map<String, UserInviteStatus>?
      _invitedUsers; // New field to store invited users and their answers
  // New field to store invited users and their answers>
  UserService userService = UserService();
  late UserManagement _userManagement;

  @override
  void initState() {
    super.initState();
    initializeVariables();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve provider management instance
    _userManagement = Provider.of<UserManagement>(context, listen: false);

    // Set the current user
    _currentUser = _userManagement.currentUser;
    if (_currentUser != null) {
      // Initialize the roles map
      setState(() {
        _userRoles[_currentUser!.userName] = 'Administrator';
      });
    }
  }

  Future<void> initializeVariables() async {
    if (widget.user != null && widget.group != null) {
      setState(() {
        _currentUser = widget.user;
        _group = widget.group;

        _invitedUsers = _group?.invitedUsers;

        // Initialize userRoles
        _userRoles[_currentUser!.userName] = 'Administrator';

        // Populate userRoles with existing group data
        _group!.invitedUsers?.forEach((username, user) {
          if (user.invitationAnswer == true) {
            _userRoles[username] = user.role;
          }
        });
      });

      // Load users in group
      for (var id in _group!.userIds) {
        User user = await userService.getUserById(id);
        setState(() {
          _usersAlreadyInGroup.add(user);
        });
      }
    }
  }

  void _searchUser(String username) async {
    try {
      final response = await userService.searchUsers(username.toLowerCase());

      if (!mounted) return;

      if (response is Map && response.containsKey('message')) {
        // Handle the case where the server returns a message
        setState(() {
          searchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            duration: Duration(seconds: 2),
          ),
        );
      } else if (response is List<String>) {
        // Handle the case where the server returns a list of users
        List<String> filteredResults = response.where((userName) {
          return !_usersAlreadyInGroup
                  .any((user) => user.userName == userName) &&
              !_userRoles.containsKey(userName);
        }).toList();

        setState(() {
          searchResults = filteredResults;
        });

        if (searchResults.isEmpty) {
          print('User not found');
        }
      }
    } catch (e) {
      print('Error searching for users: $e');
      if (mounted) {
        setState(() {
          searchResults = [];
        });
      }
    }
  }

  //Let's handle the case when the user has already a data/history entry
  void _addUser(String username) async {
    try {
      final User user = await userService.getUserByUsername(username);

      if (!mounted) return; // Check if the widget is still in the tree

      setState(() {
        // Check if the user is already in the group
        if (_userRoles.containsKey(user.userName)) {
          // Show a message that the user is already in the group
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User is already in the group: ${user.userName}'),
              duration: Duration(seconds: 2),
            ),
          );
          return; // Exit the method early
        }

        // Check if the user has an invite record
        if (_invitedUsers!.containsKey(user.userName)) {
          UserInviteStatus inviteStatus = _invitedUsers![user.userName]!;

          // Handle different invite statuses
          switch (inviteStatus.status) {
            case 'Resolved':
              if (inviteStatus.invitationAnswer == true) {
                // The user accepted the invitation but is not yet in the group
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'User has already accepted the invitation: ${user.userName}'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (inviteStatus.invitationAnswer == false) {
                // The user declined the invitation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'User has declined the invitation: ${user.userName}'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (DateTime.now()
                      .difference(inviteStatus.sendingDate)
                      .inDays >
                  5) {
                // The invitation has expired
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'User\'s invitation has expired: ${user.userName}'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              return; // Exit the method early

            case 'Unresolved':
              // The invitation is still pending
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'User\'s invitation is still pending: ${user.userName}'),
                  duration: Duration(seconds: 2),
                ),
              );
              return; // Exit the method early

            default:
              // Handle any other unexpected cases
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'User has an unknown invite status: ${user.userName}'),
                  duration: Duration(seconds: 2),
                ),
              );
              return; // Exit the method early
          }
        }

        // If the user is not in the group and has no relevant invite record, add the user
        _userRoles[user.userName] = 'Member';
        _usersAlreadyInGroup.add(user);
        widget.onDataChanged(_usersAlreadyInGroup, _userRoles);

        // Show a message when the user is added
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User added: ${user.userName}'),
            duration: Duration(seconds: 2),
          ),
        );
      });

      print('User added: ${user.userName}');
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  void _removeUser(String username) {
    if (username == _currentUser?.userName) {
      print('Cannot remove current user: $username');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.cannotRemoveYourself),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _usersAlreadyInGroup.removeWhere((u) => u.userName == username);
      _userRoles.remove(username);
      widget.onDataChanged(_usersAlreadyInGroup, _userRoles);
    });

    print('Removed user: $username');
  }

  Widget _buildSelectedUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_userRoles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                child: Text(
                  "Administrator",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentUser!.userName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: ThemeColors.getContainerBackgroundColor(context),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Administrator',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                child: Text(
                  "Users",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _userRoles.length,
                itemBuilder: (context, index) {
                  final username = _userRoles.keys.toList()[index];
                  if (username == _currentUser!.userName) return Container();
                  final userRole = _userRoles[username] ?? 'Member';

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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
                          onChanged: (newValue) {
                            setState(() {
                              _userRoles[username] = newValue!;
                              widget.onDataChanged(
                                  _usersAlreadyInGroup, _userRoles);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
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
                          _addUser(userName); // Call the addUser function here
                        },
                        icon: Icon(Icons.add),
                      ),
                      IconButton(
                        onPressed: () {
                          _removeUser(
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
