import 'package:calendar_app_frontend/a-models/user_model/user.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/utils/search_bar/selected_user_widget.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart'; // ✅ Import
import 'package:flutter/material.dart';

import 'dialog_button_widget.dart';

class UserExpandableCard extends StatefulWidget {
  final List<User> usersAvailable;
  final ValueChanged<List<User>> onSelectedUsersChanged;
  final List<User>? initiallySelected;

  const UserExpandableCard({
    Key? key,
    required this.usersAvailable,
    required this.onSelectedUsersChanged,
    this.initiallySelected,
  }) : super(key: key);

  @override
  _UserExpandableCardState createState() => _UserExpandableCardState();
}

class _UserExpandableCardState extends State<UserExpandableCard> {
  late List<User> _selectedUsers;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _selectedUsers = widget.initiallySelected ?? [];
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onUsersSelected(List<User> selectedUsers) {
    setState(() {
      _selectedUsers = selectedUsers;
    });
    widget.onSelectedUsersChanged(selectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // ✅ Localizations

    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(loc.userExpandableCardTitle), // ✅ Localized
              trailing: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
              ),
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
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(loc.noUsersSelected), // ✅ Already localized
                  ),
          ],
        ),
      ),
    );
  }
}
