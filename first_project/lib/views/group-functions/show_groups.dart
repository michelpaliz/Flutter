import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:first_project/provider/provider_management.dart';
import 'package:first_project/services/auth/implements/auth_service.dart';
import 'package:first_project/services/firestore_database/implements/firestore_service.dart';
import 'package:first_project/styles/widgets/view-item-styles/button_styles.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../enums/routes/routes.dart';
import '../../../styles/drawer-style-menu/my_drawer.dart';
import '../../../models/group.dart';
import '../../../models/user.dart';
import 'dart:developer' as devtools show log;
import "package:flutter_gen/gen_l10n/app_localizations.dart";

//---------------------------------------------------------------- This view will show the user groups associated with the user, it also offers some functionalities for the groups logic like removing, editing and adding groups.

class ShowGroups extends StatefulWidget {
  const ShowGroups({super.key});

  @override
  State<ShowGroups> createState() => _ShowGroupsState();
}

class _ShowGroupsState extends State<ShowGroups> {
  User? _currentUser;
  late FirestoreService _storeService;
  late AuthService _authService;
  // VARIABLE FOR THE UI
  Axis _scrollDirection = Axis.vertical;
  late Color textColor;
  late Color cardBackgroundColor;
  //*LOGIC FOR THE VIEW //
  @override
  void initState() {
    super.initState();
    _authService = new AuthService.firebase();
    _currentUser = _authService.costumeUser;
  }

  void _toggleScrollDirection() {
    setState(() {
      _scrollDirection =
          _scrollDirection == Axis.vertical ? Axis.horizontal : Axis.vertical;
    });
  }

  void _createGroup() {
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
          title: Text(AppLocalizations.of(context)!.confirm),
          content: Text(AppLocalizations.of(context)!.groupDeletedSuccessfully),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel the deletion
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete),
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
            content:
                Text(AppLocalizations.of(context)!.groupDeletedSuccessfully),
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
  Widget buildCard(Group group, bool isHovered) {
    textColor = ThemeColors.getTextColor(context);
    cardBackgroundColor = ThemeColors.getCardBackgroundColor(context);
    String formattedDate = DateFormat('yyyy-MM-dd').format(group.createdTime);
    Color backgroundColor = isHovered
        ? Color.fromARGB(57, 145, 182, 195)
        : Color.fromARGB(
            255, 255, 255, 255); // Sky blue when hovered, grey when not

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
            child: MouseRegion(
              onEnter: (_) {
                // Add your hover effect here (e.g., change the background color).
                setState(() {
                  isHovered = true;
                });
              },
              onExit: (_) {
                // Reset the hover effect when the mouse exits.
                setState(() {
                  isHovered = false;
                });
              },
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 3, left: 4), // Add padding
                    child: Icon(Icons.group, size: 32, color: Colors.blue),
                  ),
                  SizedBox(width: 8), // Add some spacing
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center vertically
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                                fontFamily: 'lato', color: Colors.black),
                          ),
                          SizedBox(height: 10), // Add vertical spacing
                          Text(
                            group.groupName
                                .toUpperCase(), // Uppercase group name
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(
                                  255, 48, 133, 141), // Change color
                              fontWeight: FontWeight.bold, // Make it bold
                              fontFamily: 'lato', // Use Lato font family
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        color: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProviderManagement>(
        builder: (context, providerManagement, child) {
      Color containerBackgroundColor =
          ThemeColors.getContainerBackgroundColor(context);
      // Access the list of groups from providerData.
      final List<Group> groups = providerManagement.setGroups;

      devtools.log('This is group list: ' + groups.toString());
      // Initialize _storeService using data from providerManagement.
      final providerData = providerManagement;
      _storeService = FirestoreService.firebase(providerData);
      return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(width: 8), // Adding some space between icon and text
                Text(
                  AppLocalizations.of(context)!.groups,
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
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: containerBackgroundColor,
                        borderRadius: BorderRadius.circular(
                            20.0), // Adjust the radius for rounded corners
                        border: Border.all(
                            color: const Color.fromARGB(255, 185, 210, 231),
                            width: 2.0), // Border styling
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.welcomeGroupView(
                              Utilities.capitalize(_currentUser!.name),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'lato',
                            ),
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
                                  AppLocalizations.of(context)!.changeView,
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
                      child: Consumer<ProviderManagement>(
                        builder: (context, providerManagement, child) {
                          List<Group> userGroups = providerManagement.setGroups;

                          if (userGroups.isEmpty) {
                            return Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .noGroupsAvailable
                                    .toUpperCase(),
                                style: TextStyle(fontSize: 15),
                              ),
                            );
                          }

                          return ListView.builder(
                            scrollDirection: _scrollDirection,
                            itemCount: userGroups.length,
                            itemBuilder: (context, index) {
                              bool isHovered = false;

                              return InkWell(
                                onTap: () async {
                                  Group _group = userGroups[index];
                                  User _groupOwner = await _storeService
                                      .getOwnerFromGroup(_group);
                                  showProfileAlertDialog(
                                      context, _group, _groupOwner);
                                },
                                onHover: (hovering) {
                                  // Set the hover state
                                  setState(() {
                                    isHovered = hovering;
                                  });
                                },
                                child: MouseRegion(
                                  onEnter: (_) {
                                    // Add your hover effect here (e.g., change the background color).
                                    setState(() {
                                      isHovered = true;
                                    });
                                  },
                                  onExit: (_) {
                                    // Reset the hover effect when the mouse exits.
                                    setState(() {
                                      isHovered = false;
                                    });
                                  },
                                  child:
                                      buildCard(userGroups[index], isHovered),
                                ),
                              );
                            },
                          );
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
                  color: textColor,
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
                    Text(
                      AppLocalizations.of(context)!.goToCalendar,
                      style: TextStyle(color: Colors.white),
                    ),
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
                child: Text(AppLocalizations.of(context)!.edit)),
            TextButton(
              onPressed: () {
                // Remove group logic here
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(group);
              },
              child: Text(AppLocalizations.of(context)!.remove),
            ),
          ],
        );
      },
    );
  }
}
