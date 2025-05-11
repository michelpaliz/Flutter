import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/b-group-section/utils/search_bar/selected_user_widget.dart';
import 'package:flutter/material.dart';

import 'dialog_button_widget.dart'; // Import the DialogButtonWidget here

class UserExpandableCard extends StatefulWidget {
  final List<User> usersAvailable;
  final ValueChanged<List<User>> onSelectedUsersChanged; // <-- ADD THIS

  const UserExpandableCard({
    Key? key,
    required this.usersAvailable,
    required this.onSelectedUsersChanged, // <-- AND THIS
  }) : super(key: key);

  @override
  _UserExpandableCardState createState() => _UserExpandableCardState();
}

class _UserExpandableCardState extends State<UserExpandableCard> {
  List<User> _selectedUsers = [];
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onUsersSelected(List<User> selectedUsers) {
    setState(() {
      _selectedUsers = selectedUsers;
    });

    widget.onSelectedUsersChanged(selectedUsers); // <-- NOTIFY PARENT
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Select Users'),
              trailing:
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onTap: _toggleExpansion,
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? 100 : 0,
              child: _isExpanded
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DialogButtonWidget(
                          selectedUsers: _selectedUsers,
                          usersAvailable: widget.usersAvailable,
                          onUsersSelected: _onUsersSelected,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            _selectedUsers.isNotEmpty
                ? AnimatedUsersList(users: _selectedUsers)
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('No users selected.'),
                  ),
          ],
        ),
      ),
    );
  }
}
