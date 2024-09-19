import 'package:first_project/models/group.dart';
import 'package:first_project/models/user.dart';
import 'package:first_project/models/userInvitationStatus.dart';
import 'package:first_project/services/node_services/user_services.dart';
import 'package:first_project/stateManagement/user_management.dart';
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
  Map<String, UserInviteStatus>? _invitedUsers;
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
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _currentUser = _userManagement.currentUser;

    if (_currentUser != null) {
      _setCurrentUserRole();
    }
  }

  Future<void> initializeVariables() async {
    if (widget.user != null && widget.group != null) {
      setState(() {
        _currentUser = widget.user;
        _group = widget.group;
        _invitedUsers = _group?.invitedUsers;
        _setCurrentUserRole();
        _populateUserRolesWithInvites();
      });
      await _loadGroupUsers();
    }
  }

  void _setCurrentUserRole() {
    setState(() {
      _userRoles[_currentUser!.userName] = 'Administrator';
    });
  }

  void _populateUserRolesWithInvites() {
    _group?.invitedUsers?.forEach((username, inviteStatus) {
      if (inviteStatus.invitationAnswer == true) {
        _userRoles[username] = inviteStatus.role;
      }
    });
  }

  Future<void> _loadGroupUsers() async {
    for (var id in _group!.userIds) {
      User user = await userService.getUserById(id);
      setState(() {
        _usersAlreadyInGroup.add(user);
      });
    }
  }

  void _searchUser(String username) async {
    try {
      final response = await userService.searchUsers(username.toLowerCase());

      if (!mounted) return;

      if (response is Map && response.containsKey('message')) {
        _clearSearchResults();
        _showSnackBar(response['message']);
      } else if (response is List<String>) {
        _filterSearchResults(response);
      }
    } catch (e) {
      print('Error searching for users: $e');
      _clearSearchResults();
    }
  }

  void _clearSearchResults() {
    setState(() {
      searchResults = [];
    });
  }

  void _filterSearchResults(List<String> response) {
    setState(() {
      searchResults = response
          .where((userName) =>
              !_usersAlreadyInGroup.any((user) => user.userName == userName) &&
              !_userRoles.containsKey(userName))
          .toList();

      if (searchResults.isEmpty) {
        print('User not found');
      }
    });
  }

  void _addUser(String username) async {
    try {
      final User user = await userService.getUserByUsername(username);

      if (!mounted) return;

      if (_userRoles.containsKey(user.userName)) {
        _showSnackBar('User is already in the group: ${user.userName}');
        return;
      }

      if (_invitedUsers != null && _invitedUsers!.containsKey(user.userName)) {
        _handleInviteStatus(user, _invitedUsers![user.userName]!);
        return;
      }

      _addUserToGroup(user);
    } catch (e) {
      print('Error searching for user: $e');
    }
  }

  void _handleInviteStatus(User user, UserInviteStatus inviteStatus) {
    if (inviteStatus.status == 'Resolved') {
      if (inviteStatus.invitationAnswer == true) {
        _showSnackBar('User has accepted the invitation: ${user.userName}');
      } else if (inviteStatus.invitationAnswer == false) {
        _showSnackBar('User has declined the invitation: ${user.userName}');
      } else if (_isInvitationExpired(inviteStatus)) {
        _showSnackBar('User\'s invitation has expired: ${user.userName}');
      }
    } else if (inviteStatus.status == 'Unresolved') {
      _showSnackBar('User\'s invitation is still pending: ${user.userName}');
    } else {
      _showSnackBar('User has an unknown invite status: ${user.userName}');
    }
  }

  bool _isInvitationExpired(UserInviteStatus inviteStatus) {
    return DateTime.now().difference(inviteStatus.sendingDate).inDays > 5;
  }

  void _addUserToGroup(User user) {
    setState(() {
      _userRoles[user.userName] = 'Member';
      _usersAlreadyInGroup.add(user);
      widget.onDataChanged(_usersAlreadyInGroup, _userRoles);
      _showSnackBar('User added: ${user.userName}');
    });
  }

  void _removeUser(String username) {
    if (username == _currentUser?.userName) {
      _showSnackBar(AppLocalizations.of(context)!.cannotRemoveYourself);
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
        _buildAdminSection(),
        if (_userRoles.isNotEmpty) _buildUsersList() else _buildEmptyState(),
      ],
    );
  }

  Widget _buildAdminSection() {
    if (_userRoles.isEmpty) return Container();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_currentUser!.userName, style: _boldTextStyle()),
          _roleBadge('Administrator'),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _userRoles.length,
      itemBuilder: (context, index) {
        final username = _userRoles.keys.toList()[index];
        if (username == _currentUser!.userName) return Container();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: GestureDetector(
            onTap: () {
              _showRoleChangeDialog(username);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(username, style: _boldTextStyle()),
                _roleBadge(_userRoles[username]!),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removeUser(username),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRoleChangeDialog(String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Role for $username'),
          content: DropdownButton<String>(
            value: _userRoles[username],
            items: [
              DropdownMenuItem(value: 'Member', child: Text('Member')),
              DropdownMenuItem(
                  value: 'Co-Administrator', child: Text('Co-Administrator')),
            ],
            onChanged: (value) {
              setState(() {
                _userRoles[username] = value!;
                widget.onDataChanged(_usersAlreadyInGroup, _userRoles);
              });
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text('No users in group', style: TextStyle(fontSize: 16)),
    );
  }

  TextStyle _boldTextStyle() {
    return TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
  }

  Widget _roleBadge(String role) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade300,
      ),
      child: Text(role, style: TextStyle(color: Colors.black, fontSize: 14)),
    );
  }

  Widget _roleDropdown(String username) {
    return DropdownButton<String>(
      value: _userRoles[username],
      items: [
        DropdownMenuItem(value: 'Member', child: Text('Member')),
        DropdownMenuItem(
            value: 'Co-Administrator', child: Text('Co-Administrator')),
      ],
      onChanged: (value) {
        setState(() {
          _userRoles[username] = value!;
          widget.onDataChanged(_usersAlreadyInGroup, _userRoles);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        SizedBox(height: 10),
        _buildSelectedUsersList(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSearchBar(
          controller: _searchController,
          onChanged: (username) {
            if (username.length >= 3) {
              _searchUser(username);
            } else {
              _clearSearchResults();
            }
          },
          onSearch: () {
            if (_searchController.text.length >= 3) {
              _searchUser(_searchController.text);
            }
          },
          onClear: () {
            _searchController.clear();
            _clearSearchResults();
          },
        ),
        _buildSearchResults(),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) return Container();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Column(
        children: searchResults.map((username) {
          return GestureDetector(
            onTap: () {
              _addUser(username);
              _searchController.clear();
              setState(() {
                searchResults.clear();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(username, style: _boldTextStyle()),
                  Icon(Icons.add, color: Colors.green),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
