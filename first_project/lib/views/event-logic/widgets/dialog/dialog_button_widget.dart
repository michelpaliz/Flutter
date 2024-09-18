import 'package:first_project/models/user.dart';
import 'package:flutter/material.dart';

class DialogButtonWidget extends StatefulWidget {
  final List<User> selectedUsers; // List of selected users passed as a parameter
  final List<User> usersAvailable; // List of all available users
  final void Function(List<User>) onUsersSelected; // Callback to update selected users

  const DialogButtonWidget({
    Key? key,
    required this.selectedUsers,
    required this.usersAvailable,
    required this.onUsersSelected, // Initialize callback
  }) : super(key: key);

  @override
  _DialogButtonWidgetState createState() => _DialogButtonWidgetState();
}

class _DialogButtonWidgetState extends State<DialogButtonWidget> {
  late List<User> _selectedUsers;

  @override
  void initState() {
    super.initState();
    _selectedUsers = List.from(widget.selectedUsers); // Initialize with selected users
  }

  // Method to show the user selection dialog
  void _showUserSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select users for this event'),
              content: Container(
                width: 300, // Set a fixed width for the dialog
                height: 150, // Set a fixed height for the dialog
                child: _buildUserSelection(context, setState),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onUsersSelected(_selectedUsers); // Pass updated users back
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Method to build the user selection list
  Widget _buildUserSelection(BuildContext context, StateSetter setState) {
    return ListView.builder(
      itemCount: widget.usersAvailable.length,
      itemBuilder: (context, index) {
        final user = widget.usersAvailable[index];
        final isSelected = _selectedUsers.contains(user);

        return CheckboxListTile(
          title: Text(user.userName),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedUsers.add(user);
              } else {
                _selectedUsers.remove(user);
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _showUserSelectionDialog(context),
        child: Text('Show User Selection'),
      ),
    );
  }
}
