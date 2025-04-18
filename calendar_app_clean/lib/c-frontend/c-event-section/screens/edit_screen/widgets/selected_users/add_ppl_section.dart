import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/controllers/create_group_controller.dart';
import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/widgets/create_group_search_bar.dart';
import 'package:flutter/material.dart';

class AddPeopleSection extends StatelessWidget {
  final User? currentUser;
  final Group? group;
  final GroupController controller; // ✅ pass this from parent

  const AddPeopleSection({
    required this.currentUser,
    required this.group,
    required this.controller,
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
                          group: group,
                          user: currentUser,
                          controller: controller, // ✅ pass controller
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
