import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/services/user/user_provider.dart';
import 'package:flutter/material.dart';
import '../constants/routes.dart';
import '../costume_widgets/drawer/my_drawer.dart';
import '../models/group.dart';
import '../models/user.dart';
import '../styles/app_bar_styles.dart';

//---------------------------------------------------------------- I would like to add 1 button to create a group so the user can add ppl to share a calendar, and above the button there will be a list of groups that the current user has and if there is no groups there will be a message saying "There is no groups available"

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  User? currentUser;
  List<Group>? userGroups =
      []; // List to store the groups that the current user has
  StoreService storeService = new StoreService.firebase();
  AuthService authService = new AuthService.firebase();

  //*LOGIC FOR THE VIEW //
  Future<void> _getCurrentUser() async {
    currentUser = await getCurrentUser();
    if (currentUser != null) {
      userGroups = await fetchUserGroups(currentUser!.groupIds);
    } else {
      userGroups = null;
    }
    setState(() {}); // Trigger a rebuild after getting the currentUser
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _createGroup() {
    // Implement the create group functionality similar to the previous example.
    // Add the newly created group ID to the currentUser's groupIds list, and then update the userGroups list.
    // Don't forget to call setState() after updating the userGroups list.
    Navigator.pushNamed(context, createGroup);
    // Call setState to trigger a UI update
    setState(() {});
  }

  Future<List<Group>> fetchUserGroups(List<String>? groupIds) async {
    List<Group> groups = [];

    if (groupIds != null) {
      for (String groupId in groupIds) {
        Group? group = await storeService.getGroupFromId(groupId);
        if (group != null) {
          groups.add(group);
        }
      }
    }

    return groups;
  }

  //** UI FOR THE VIEW */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(Icons.dashboard), // Icon next to "Dashboard" text
              // SizedBox(width: 8), // Adding some space between icon and text
              Text(
                "Dashboard",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message), // Icon for the new button
            onPressed: () {
              // Add your onPressed logic here
              Navigator.pushNamed(context, showNotifications);
            },
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          if (userGroups == null || userGroups!.isEmpty)
            Center(child: Text("There are no groups available"))
          else
            Expanded(
              child: ListView.builder(
                itemCount: userGroups!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(userGroups![index].groupName),
                    onTap: () {
                      Group selectedGroup = userGroups![index];
                      Navigator.pushNamed(
                        context,
                        groupDetails, // Replace with the route name for group details page
                        arguments: selectedGroup,
                      );
                    },
                  );
                },
              ),
            ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                _createGroup();
              },
              child: Text("Create Group"),
            ),
          ),
        ],
      ),
    );
  }
}
