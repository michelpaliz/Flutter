import 'package:first_project/views/provider/provider_management.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore/implements/firestore_service.dart';
import 'package:first_project/styles/button_styles.dart';
import 'package:first_project/my-lib/utilities.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../enums/routes/routes.dart';
import '../../styles/costume_widgets/drawer/my_drawer.dart';
import '../../models/group.dart';
import '../../models/user.dart';

//---------------------------------------------------------------- This view will show the user groups associated with the user, it also offers some functionalities for the groups logic like removing, editing and adding groups.

class ShowGroups extends StatefulWidget {
  const ShowGroups({super.key});

  @override
  State<ShowGroups> createState() => _ShowGroupsState();
}

class _ShowGroupsState extends State<ShowGroups> {
  User? _currentUser;
  late List<Group>? _userGroups;
  late StoreService _storeService;
  late AuthService _authService;
  // VARIABLE FOR THE UI
  Axis _scrollDirection = Axis.vertical;

  //*LOGIC FOR THE VIEW //

  Future<List<Group>> _getUserGroups(StoreService storeService) async {
    _currentUser = _authService.costumeUser!;

    List<Group>? fetchedGroups =
        await storeService.fetchUserGroups(_currentUser?.groupIds);
    return fetchedGroups;
  }

  @override
  void initState() {
    super.initState();
    _authService = new AuthService.firebase();
    _currentUser = _authService.costumeUser;
    _userGroups = [];
    // _getUserGroups();
  }

  void _toggleScrollDirection() {
    setState(() {
      _scrollDirection =
          _scrollDirection == Axis.vertical ? Axis.horizontal : Axis.vertical;
    });
  }

  void _createGroup() {
    // Implement the create group functionality similar to the previous example.
    // Add the newly created group ID to the currentUser's groupIds list, and then update the userGroups list.
    // Don't forget to call setState() after updating the userGroups list.
    Navigator.pushNamed(context, createGroupData);
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
  Widget buildCard(
    Group group,
  ) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(group.createdTime);

    return Container(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: SizedBox(
          width: 150, // Set a fixed width
          child: GestureDetector(
            onTap: () async {
              User _groupOwner = await _storeService.getOwnerFromGroup(group);
              showProfileAlertDialog(context, group, _groupOwner);
            },
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0), // Add padding
                  child: Icon(Icons.group, size: 32, color: Colors.blue),
                ),
                SizedBox(width: 8), // Add some spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    children: [
                      Text(formattedDate),
                      SizedBox(height: 10), // Add vertical spacing
                      Text(
                        group.groupName.toUpperCase(), // Uppercase group name
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              Color.fromARGB(255, 48, 133, 141), // Change color
                          fontWeight: FontWeight.bold, // Make it bold
                          fontFamily: 'Lato', // Use Lato font family
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderManagement>(
        builder: (context, providerManagement, child) {
      // Access the list of groups from providerData.
      final List<Group> groups = providerManagement.groups;
      // Initialize _storeService using data from providerManagement.
      final providerData = providerManagement;
      _storeService = StoreService.firebase(providerData);
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(width: 8), // Adding some space between icon and text
                Text(
                  "Groups",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            if (_currentUser?.hasNewNotifications == true)
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
                  _currentUser?.hasNewNotifications = false;
                  _storeService.updateUser(_currentUser!);
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
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: Center(
                          child: Text(
                            "Welcome to the groups view ${Utilities.capitalize(_currentUser!.name)} here you can see the groups you are in",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'lato'),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Change View",
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(
                                    width:
                                        10), // Add space between text and icon
                                GestureDetector(
                                  onTap:
                                      _toggleScrollDirection, // Toggle the scroll direction
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.dashboard,
                                      // Add your icon properties here
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: _scrollDirection == Axis.vertical ? 500 : 130,
                      child: FutureBuilder<List<Group>>(
                        future: Future.value(
                            Provider.of<ProviderManagement>(context).groups),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Display a loading indicator while waiting for the data.
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            // Handle any errors that occur during the data retrieval.
                            return Center(
                                child: Text("Error: ${snapshot.error}"));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            // Handle the case where there are no groups available.
                            return Center(
                              child: Text(
                                "NO GROUP/S FOUND/S",
                                style: TextStyle(fontSize: 15),
                              ),
                            );
                          } else {
                            // Data is available, display the list of groups.
                            List<Group> userGroups = snapshot.data!;
                            return ListView.builder(
                              scrollDirection: _scrollDirection,
                              itemCount: userGroups.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    Group _group = userGroups[index];
                                    User _groupOwner = await _storeService
                                        .getOwnerFromGroup(_group);
                                    showProfileAlertDialog(
                                        context, _group, _groupOwner);
                                  },
                                  child: buildCard(userGroups[index]),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _createGroup();
          },
          child: Icon(Icons.group_add_rounded),
        ),
      );
    });
  }

  void showProfileAlertDialog(BuildContext context, Group group, User owner) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30, // Adjust the size as needed
                backgroundImage:
                    Utilities.buildProfileImage(group.photo.toString()),
              ),

              SizedBox(height: 8), // Add some spacing
              Text(
                group.groupName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8), // Add some spacing
              Text(
                "${DateFormat('yyyy-MM-dd').format(group.createdTime)}",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    groupCalendar,
                    arguments: group,
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_month_rounded),
                    SizedBox(width: 8),
                    Text('Go to calendar',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
                style: ButtonStyles.saucyButtonStyle(
                  defaultBackgroundColor: Color.fromARGB(255, 229, 117, 151),
                  pressedBackgroundColor: Color.fromARGB(255, 227, 62, 98),
                  textColor: const Color.fromARGB(255, 26, 26, 26),
                  borderColor: const Color.fromARGB(255, 53, 10, 7),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Edit group logic here
                Group? groupUpdated =
                    await _storeService.getGroupFromId(group.id);
                Navigator.pushNamed(context, editGroupData,
                    arguments: groupUpdated);
              },
              child: Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                // Remove group logic here
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(group);
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}
