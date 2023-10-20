import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/routes.dart';
import '../costume_widgets/drawer/my_drawer.dart';
import '../models/group.dart';
import '../models/user.dart';

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
  late StoreService _storeService;
  late AuthService _authService;

  //*LOGIC FOR THE VIEW //


  Future<List<Group>> _getUserGroups() async {
    currentUser = _authService.costumeUser;
    if (currentUser != null) {
      List<Group>? fetchedGroups =
          await _storeService.fetchUserGroups(currentUser!.groupIds);
      return fetchedGroups;
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _storeService = new StoreService.firebase();
    _authService = new AuthService.firebase();
    userGroups = [];
    _getUserGroups();
  }

  void _createGroup() {
    // Implement the create group functionality similar to the previous example.
    // Add the newly created group ID to the currentUser's groupIds list, and then update the userGroups list.
    // Don't forget to call setState() after updating the userGroups list.
    Navigator.pushNamed(context, createGroup);
    // Call setState to trigger a UI update
    setState(() {});
  }

  Future<void> _showDeleteConfirmationDialog(Group group) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this group?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm the deletion
              },
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      try {
        // Perform the group removal logic here
        await _storeService.deleteGroup(group.id);

        // Show a success message using a SnackBar
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Group deleted successfully!"),
          ),
        );

        // Call setState to update the UI
        setState(() {});
      } catch (error) {
        // Handle the error
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Error deleting group: $error"),
          ),
        );
      }
    }
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
            icon: Icon(Icons.refresh), // Add refresh icon
            onPressed: () async {
              await _getUserGroups();
            },
          ),
          if (currentUser?.hasNewNotifications == true)
            IconButton(
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(Icons.notifications),
                  Icon(Icons.brightness_1, size: 10, color: Colors.red),
                ],
              ),
              onPressed: () {
                // Open notifications screen
                currentUser?.hasNewNotifications = false;
                _storeService.updateUser(currentUser!);
                setState(() {}); // Trigger UI update
                Navigator.pushNamed(context, showNotifications);
              },
            )
          else
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Open notifications screen
                Navigator.pushNamed(context, showNotifications);
              },
            ),
        ],
      ),
      drawer: MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Center(
              child: Text(
                "Groups", // Add your desired title here
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Group>>(
              future: _getUserGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Display a loading indicator while waiting for the data.
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Handle any errors that occur during the data retrieval.
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // Handle the case where there are no groups available.
                  return Center(child: Text("There are no groups available"));
                } else {
                  // Data is available, display the list of groups.
                  List<Group> userGroups = snapshot.data!;
                  return ListView.builder(
                    itemCount: userGroups.length,
                    itemBuilder: (context, index) {
                      Group group = userGroups[index];
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(group.createdTime);

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          title: Text("${group.groupName} - $formattedDate"),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              groupCalendar,
                              arguments: group,
                            );
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () async {
                                  Group? groupUpdated = await _storeService
                                      .getGroupFromId(group.id);
                                  Navigator.pushNamed(context, editGroup,
                                      arguments: groupUpdated);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(group);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
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
