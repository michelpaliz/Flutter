import 'package:first_project/a-models/model/user_data/user.dart';
import 'package:flutter/material.dart';

import 'dialog_button_widget.dart'; // Make sure to import DialogButtonWidget

class UserDropdownTrigger extends StatefulWidget {
  final List<User> usersAvailable;

  const UserDropdownTrigger({
    Key? key,
    required this.usersAvailable,
  }) : super(key: key);

  @override
  _UserDropdownTriggerState createState() => _UserDropdownTriggerState();
}

class _UserDropdownTriggerState extends State<UserDropdownTrigger> {
  List<User> _selectedUsers = []; // List to hold selected users
  bool _isUserSelectionVisible = false; // Track visibility of the user selection widget

  // Toggles visibility of the DialogButtonWidget
  void _toggleUserSelection() {
    setState(() {
      _isUserSelectionVisible = !_isUserSelectionVisible; // Toggle visibility
    });
  }

  // Callback to update selected users
  void _updateSelectedUsers(List<User> selectedUsers) {
    setState(() {
      _selectedUsers = selectedUsers; // Update selected users
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Button that triggers showing/hiding the user selection widget
        ElevatedButton(
          onPressed: _toggleUserSelection,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select Users'),
              Icon(
                _isUserSelectionVisible
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
              ), // Change icon based on visibility
            ],
          ),
        ),
        SizedBox(height: 10.0),

        // Conditionally show the DialogButtonWidget based on _isUserSelectionVisible
        if (_isUserSelectionVisible)
          DialogButtonWidget(
            selectedUsers: _selectedUsers,
            usersAvailable: widget.usersAvailable,
            onUsersSelected: _updateSelectedUsers, // Pass the callback
          ),
      ],
    );
  }
}
