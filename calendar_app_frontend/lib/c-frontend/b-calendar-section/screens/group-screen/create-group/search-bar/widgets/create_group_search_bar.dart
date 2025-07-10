import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/create-group/search-bar/controllers/create_group_controller.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/create-group/search-bar/widgets/group_selected_user_list.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/utils/search_bar/custome_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/search_controller.dart';

class CreateGroupSearchBar extends StatefulWidget {
  final User? user;
  final Group? group;
  final GroupController controller;

  const CreateGroupSearchBar({
    super.key,
    required this.user,
    required this.group,
    required this.controller,
  });

  @override
  State<CreateGroupSearchBar> createState() => _CreateGroupSearchBarState();
}

class _CreateGroupSearchBarState extends State<CreateGroupSearchBar> {
  late GroupSearchController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = GroupSearchController(
      currentUser: widget.user,
      group: widget.group,
    );
  }

  // Function to handle confirmation (without sending to the backend for now)
  void _onConfirmChanges() {
    // Simply update the state with selected users and roles
    widget.controller.onDataChanged(
      _controller.usersInGroup,
      _controller.userRoles,
    );
    // Show a message or do something locally here
    _showSnackBar("Changes confirmed (not sent to backend yet).");
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<GroupSearchController>(
        builder: (context, ctrl, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  if (query.length >= 3) {
                    ctrl.searchUser(query, context);
                  } else {
                    ctrl.searchResults.clear();
                  }
                },
                onSearch: () {
                  if (_searchController.text.length >= 3) {
                    ctrl.searchUser(_searchController.text, context);
                  }
                },
                onClear: () {
                  _searchController.clear();
                  ctrl.searchResults.clear();
                },
              ),
              const SizedBox(height: 10),
              ...ctrl.searchResults.map((username) {
                return ListTile(
                  title: Text(username),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () {
                      ctrl.addUser(username, context);
                      _searchController.clear();
                      _showSnackBar('User added: $username');
                    },
                  ),
                );
              }),
              const SizedBox(height: 10),
              GroupSelectedUsersList(
                currentUser: widget.user!,
                usersInGroup: ctrl.usersInGroup,
                userRoles: ctrl.userRoles,
                onRemoveUser: (username) {
                  ctrl.removeUser(username);
                  _showSnackBar(
                    'User removed: $username',
                  ); // ✅ Add feedback here
                },
                onRoleChanged: (username, newRole) {
                  ctrl.changeRole(username, newRole);
                  _showSnackBar(
                    'Role updated: $username is now $newRole',
                  ); // ✅ Feedback here
                },
                onConfirmChanges:
                    _onConfirmChanges, // Confirm changes without backend
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
