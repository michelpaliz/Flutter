import 'package:first_project/models/user.dart';
import 'package:first_project/styles/widgets/view-item-styles/selected_user_widget.dart';
import 'package:flutter/material.dart';

import 'dialog_button_widget.dart'; // Import the DialogButtonWidget here

class UserExpandableCard extends StatefulWidget {
  final List<User> usersAvailable;

  const UserExpandableCard({
    Key? key,
    required this.usersAvailable,
  }) : super(key: key);

  @override
  _UserExpandableCardState createState() => _UserExpandableCardState();
}

class _UserExpandableCardState extends State<UserExpandableCard> {
  List<User> _selectedUsers = []; // List to hold selected users
  bool _isExpanded = false; // Track whether the card is expanded

  // Toggles the expansion of the card
  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded; // Toggle expansion
    });
  }

  // Method to handle user selection
  void _onUsersSelected(List<User> selectedUsers) {
    setState(() {
      _selectedUsers = selectedUsers; // Update the selected users
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding to the Card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Select Users'),
              trailing: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ), // Change icon based on expansion state
              onTap: _toggleExpansion,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300), // Animation duration
              height: _isExpanded ? 100 : 0, // Adjust height based on expansion
              child: _isExpanded
                  ? SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0), // Add padding to the scroll view
                        child: DialogButtonWidget(
                          selectedUsers: _selectedUsers,
                          usersAvailable: widget.usersAvailable,
                          onUsersSelected: _onUsersSelected, // Pass callback
                        ),
                      ),
                    )
                  : SizedBox.shrink(), // Show empty space if collapsed
            ),
            // SizedBox(height: 10.0),
            // Display the selected users below the button
            _selectedUsers.isNotEmpty
                ? AnimatedUsersList(users: _selectedUsers)
                : Padding(
                    padding: const EdgeInsets.all(8.0), // Add padding to the text
                    child: Text('No users selected.'),
                  ),
          ],
        ),
      ),
    );
  }
}
