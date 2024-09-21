import 'package:first_project/a-models/group.dart';
import 'package:first_project/a-models/user.dart';
import 'package:first_project/c-frontend/a-group-section/views/create_group_search_bar.dart';
import 'package:flutter/material.dart';

class AddPeopleSection extends StatelessWidget {
  final User? currentUser;
  final Group? group;
  final Function onDataChanged;

  const AddPeopleSection({
    required this.currentUser,
    required this.group,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Add People to Group', style: TextStyle(color: Colors.grey)),
        SizedBox(width: 15),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Add People to Group',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: CreateGroupSearchBar(
                          group: group, onDataChanged: (List<User> usersInGroup, Map<String, String> userRoles) {  }, user: currentUser,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Center(child: Text('Add User')),
        ),
      ],
    );
  }
}
