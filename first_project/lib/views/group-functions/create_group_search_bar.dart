import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:first_project/styles/widgets/view-item-styles/costume_search_bar.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

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
  Map<String, String> userRoles = {};
  late List<String> filteredItems;
  TextEditingController _searchController = TextEditingController();
  User? _currentUser;
  Group? _group;
  List<User> _usersInGroup = [];
  UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    initializeVariables();
  }

  Future<void> initializeVariables() async {
    if (widget.user != null && widget.group != null) {
      setState(() {
        _currentUser = widget.user;
        _group = widget.group;

        // Initialize userRoles
        userRoles.clear();
        userRoles[_currentUser!.userName] =
            'Administrator'; // Current user is Administrator

        // Iterate over invitedUsers map entries
        _group!.invitedUsers?.forEach((username, user) {
          if (user.accepted == true) {
            userRoles[username] =
                user.role;
          }
        });
      });

      for (var id in _group!.userIds) {
        User user = await userService.getUserById(id);
        _usersInGroup.add(user);
      }
    }
  }

  void _searchUser(String username) async {
    try {
      final List<String> foundUsers =
          await userService.searchUsers(username.toLowerCase());

      if (!mounted) return;

      List<String> filteredResults = foundUsers.where((userName) {
        return !_usersInGroup.any((user) => user.userName == userName) &&
            !userRoles.containsKey(userName);
      }).toList();

      setState(() {
        searchResults = filteredResults;
      });

      if (searchResults.isEmpty) {
        print('User not found');
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

  void addUser(String username) async {
    try {
      final User user = await userService.getUserByUsername(username);

      setState(() {
        if (!userRoles.containsKey(user.userName)) {
          userRoles[user.userName] = 'Member';
          _usersInGroup.add(user);
          widget.onDataChanged(_usersInGroup, userRoles);
        }
      });

      print('User added: ${user.userName}');
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  void removeUser(String username) {
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
      _usersInGroup.removeWhere((u) => u.userName == username);
      userRoles.remove(username);
      widget.onDataChanged(_usersInGroup, userRoles);
    });

    print('Removed user: $username');
  }

  Widget _buildSelectedUsersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userRoles.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: userRoles.length,
                  itemBuilder: (context, index) {
                    final username = userRoles.keys.toList()[index];
                    final userRole = userRoles[username] ?? 'Member';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (username == _currentUser!.userName)
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
                              onChanged: (newValue) {
                                setState(() {
                                  userRoles[username] = newValue!;
                                  widget.onDataChanged(
                                      _usersInGroup, userRoles);
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
                            _clickedUser = null;
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
