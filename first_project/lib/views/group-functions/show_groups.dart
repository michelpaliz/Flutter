import 'package:first_project/models/notification_user.dart';
import 'package:first_project/services/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/services/firebase_%20services/firestore_database/logic_backend/firestore_service.dart';
import 'package:first_project/stateManangement/provider_management.dart';
import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:first_project/styles/widgets/view-item-styles/button_styles.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../models/group.dart';
import '../../../models/user.dart';
import '../../enums/routes/appRoutes.dart';
import 'dart:developer' as devtools show log;

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
  String? _currentRole;
  ProviderManagement? _providerManagement;

  //*LOGIC FOR THE VIEW //

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _authService = AuthService.firebase();
    _currentUser = _authService.costumeUser;
    _providerManagement =
        Provider.of<ProviderManagement>(context, listen: false);
    _storeService = FirestoreService.firebase(_providerManagement!);
    await _fetchAndUpdateGroups();
  }

  Future<void> _fetchAndUpdateGroups() async {
    try {
      List<Group> fetchedGroups =
          await _storeService.fetchUserGroups(_currentUser!.groupIds);
      _providerManagement?.updateGroupStream(fetchedGroups);
      devtools.log(_currentUser!.groupIds.toString());
      devtools.log(fetchedGroups.toString());
    } catch (error) {
      print('Error fetching and updating groups: $error');
    }
  }

  void _toggleScrollDirection() {
    setState(() {
      _scrollDirection =
          _scrollDirection == Axis.vertical ? Axis.horizontal : Axis.vertical;
    });
  }

  void _createGroup() {
    Navigator.pushNamed(context, AppRoutes.createGroupData);
    // Call setState to trigger a UI update
    setState(() {});
  }

  String _getRole(User currentUser, Map<String, String> userRoles) {
    return userRoles[currentUser.userName] ?? 'No Role Found';
  }

  bool _hasPermissions(Group groupSelected) {
    _currentRole = _getRole(_currentUser!, groupSelected.userRoles);
    return _currentRole == "Administrator";
  }

  void _showDeleteConfirmationDialog(Group group) async {
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

    if (deleteConfirmed == true && mounted) {
      // Check if widget is mounted
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

  void _leaveGroup(BuildContext context, Group group) async {
    // Check if the current user is the admin of the group
    bool isGroupAdmin = _providerManagement!.currentUser!.id == group.ownerId;

    // Display confirmation dialog with custom message for admin
    bool confirm = await _showConfirmationDialog(
      context,
      isGroupAdmin
          ? 'Are you sure you want to dissolve this group?'
          : 'Are you sure you want to leave this group?',
    );

    if (confirm) {
      // If the user confirms, remove the user from the group
      await _storeService.removeUserInGroup(_currentUser!, group);
    }
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirm'),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(false); // Return false when canceled
                  },
                ),
                TextButton(
                  child: Text('Confirm'),
                  onPressed: () {
                    Navigator.of(context)
                        .pop(true); // Return true when confirmed
                  },
                ),
              ],
            );
          },
        ) ??
        false; // Default to false if dialog is dismissed without confirmation
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
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        child: Icon(Icons.group_add_rounded),
      ),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        title: Text(AppLocalizations.of(context)!.groups),
        actions: [
          _buildNotificationIconButton(context),
        ],
      ),
    );
  }
  // }

  Widget _buildNotificationIconButton(BuildContext context) {
    return StreamBuilder<List<NotificationUser>>(
      stream: _providerManagement!.notificationStream,
      initialData: [],
      builder: (context, snapshot) {
        final hasNewNotifications =
            snapshot.hasData ? snapshot.data!.isNotEmpty : false;
        if (hasNewNotifications) {
          return IconButton(
            icon: Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(Icons.notifications),
                Icon(Icons.brightness_1, size: 10, color: Colors.red),
              ],
            ),
            onPressed: () {
              _providerManagement!.clearNotifications(); // Clear notifications
              Navigator.pushNamed(context, AppRoutes.showNotifications);
            },
          );
        } else {
          return IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.showNotifications);
            },
          );
        }
      },
    );
  }

  Widget buildBody(BuildContext context) {
    return StreamBuilder<List<Group>>(
      stream: _providerManagement?.groupStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Group> groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return Center(child: Text('No groups available.'));
          }
          return Column(
            children: [
              _buildWelcomeContainer(context),
              _buildChangeViewRow(context),
              SizedBox(height: 20),
              _buildGroupListView(groups),
            ],
          );
        }
      },
    );
  }

  Widget _buildWelcomeContainer(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.getContainerBackgroundColor(context),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color.fromARGB(255, 185, 210, 231),
          width: 2.0,
        ),
      ),
      padding: EdgeInsets.all(16.0),
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
    );
  }

  Widget _buildChangeViewRow(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.changeView,
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: _toggleScrollDirection,
            child: Align(
              alignment: Alignment.center,
              child: Icon(Icons.dashboard),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupListView(List<Group> groups) {
    return Container(
      height: _scrollDirection == Axis.vertical ? 500 : 130,
      child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(height: 10),
        scrollDirection: _scrollDirection,
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return buildGroupCard(groups[index]);
        },
      ),
    );
  }

  Widget buildGroupCard(Group group) {
    bool isHovered = false;

    return InkWell(
      onTap: () async {
        User groupOwner = await _storeService.getOwnerFromGroup(group);
        showProfileAlertDialog(context, group, groupOwner);
      },
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() {
            isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            isHovered = false;
          });
        },
        child: buildCard(group, isHovered),
      ),
    );
  }

  //? This shows the groups list
  void showProfileAlertDialog(BuildContext context, Group group, User owner) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //** GROUP IMAGE */
              CircleAvatar(
                radius: 30, // Adjust the size as needed
                backgroundImage:
                    Utilities.buildProfileImage(group.photo.toString()),
              ),
              SizedBox(height: 8), // Add some spacing
              //** GROUP NAME */
              Text(
                group.groupName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 8), // Add some spacing
              //** GROUP DATE */
              Text(
                "${DateFormat('yyyy-MM-dd').format(group.createdTime)}",
                style: TextStyle(
                  color: textColor,
                ),
              ),
              SizedBox(height: 15),
              //** GROUP CALENDAR */
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.groupCalendar,
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
              ),
            ],
          ),
          //** HERE ARE THE ACTIONS LIKE; EDIT GROUP AND REMOVE GROUP */
          actions: _hasPermissions(group)
              ? [
                  TextButton(
                    onPressed: () async {
                      // Edit group logic here
                      var selectedGroup =
                          await _storeService.getGroupFromId(group.id);
                      Navigator.pushNamed(context, AppRoutes.editGroupData,
                          arguments: selectedGroup);
                    },
                    child: Text(AppLocalizations.of(context)!.edit),
                  ),
                  TextButton(
                    onPressed: () {
                      // Remove group logic here
                      Navigator.of(context).pop();
                      _showDeleteConfirmationDialog(group);
                    },
                    child: Text(AppLocalizations.of(context)!.remove),
                  ),
                ]
              : [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                        "Currently you are a/an $_currentRole of this group "),
                    // child: Text(AppLocalizations.of(context)!
                    //     .noPermissionMessage), // Replace with your localized message
                  ),
                  TextButton(
                    onPressed: () {
                      _leaveGroup(context, group);
                    },
                    child: Text("Leave group"),
                    // child: Text(AppLocalizations.of(context)!
                    //     .noPermissionMessage), // Replace with your localized message
                  )
                ],
        );
      },
    );
  }
}
