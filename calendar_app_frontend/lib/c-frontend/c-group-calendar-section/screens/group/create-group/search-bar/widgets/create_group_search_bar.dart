import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/a-models/user_model/user.dart';
import 'package:hexora/b-backend/group_mng_flow/group/view_model/group_view_model.dart';
import 'package:hexora/b-backend/auth_user/user/repository/user_repository.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/create-group/search-bar/controllers/search_controller.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/screens/group/create-group/search-bar/widgets/group_selected_user_list.dart';
import 'package:hexora/c-frontend/c-group-calendar-section/utils/search_bar/custome_search_bar.dart';
import 'package:provider/provider.dart';

class CreateGroupSearchBar extends StatefulWidget {
  final User? user;
  final Group? group;
  final GroupViewModel controller;

  /// Callback triggered when a user is added (for parent preview updates)
  final void Function(User)? onUserPicked;

  const CreateGroupSearchBar({
    super.key,
    required this.user,
    required this.group,
    required this.controller,
    this.onUserPicked,
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

    // delay until context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<UserRepository>();

      setState(() {
        _controller = GroupSearchController(
          currentUser: widget.user,
          group: widget.group,
          userRepository: repo, // ← required
        );
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Apply local changes (does not persist to backend yet)
  void _onConfirmChanges() {
    widget.controller.onDataChanged(
      _controller.usersInGroup,
      _controller.userRoles,
    );
    _showSnackBar("✅ Local changes applied.");
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
                    ctrl.clearResults();
                  }
                },
                onSearch: () {
                  if (_searchController.text.length >= 3) {
                    ctrl.searchUser(_searchController.text, context);
                  }
                },
                onClear: () {
                  _searchController.clear();
                  ctrl.clearResults();
                },
              ),
              const SizedBox(height: 10),

              // Search results
              ...ctrl.searchResults.map((username) {
                return ListTile(
                  title: Text(username),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, color: Colors.green),
                    onPressed: () async {
                      final addedUser = await ctrl.addUser(username, context);
                      _searchController.clear();

                      if (addedUser != null) {
                        _showSnackBar('User added: $username');
                        widget.onUserPicked?.call(addedUser);
                      } else {
                        _showSnackBar('⚠️ Failed to add user: $username');
                      }
                    },
                  ),
                );
              }),

              const SizedBox(height: 10),

              // Selected users
              GroupSelectedUsersList(
                currentUser: widget.user!,
                usersInGroup: ctrl.usersInGroup,
                userRoles: ctrl.userRoles,
                onRemoveUser: (username) {
                  ctrl.removeUser(username);
                  _showSnackBar('User removed: $username');
                },
                onRoleChanged: (username, newRole) {
                  ctrl.changeRole(username, newRole);
                  _showSnackBar('Role updated: $username → $newRole');
                },
                onConfirmChanges: _onConfirmChanges,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
