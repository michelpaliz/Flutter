import 'dart:developer' as devtools show log;

import 'package:first_project/a-models/notification_user.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/notification_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:first_project/styles/widgets/view-item-styles/button_styles.dart';
import 'package:first_project/utilities/utilities.dart';
import 'package:first_project/c-frontend/a-group-section/views/edit_group_data.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../a-models/group.dart';
import '../../../a-models/user.dart';
import '../../../enums/routes/appRoutes.dart';

//---------------------------------------------------------------- This view will show the user groups associated with the user, it also offers some functionalities for the groups logic like removing, editing and adding groups.

class ShowGroups extends StatefulWidget {
  const ShowGroups({super.key});

  @override
  State<ShowGroups> createState() => _ShowGroupsState();
}

class _ShowGroupsState extends State<ShowGroups> {
  User? _currentUser;
  Axis _scrollDirection = Axis.vertical;
  late Color textColor;
  late Color cardBackgroundColor;
  String? _currentRole;
  late UserManagement? _userManagement;
  late GroupManagement _groupManagement;

  //*LOGIC FOR THE VIEW //

  @override
  void initState() {
    super.initState();
  }

  // @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //Init our services
    _userManagement = Provider.of<UserManagement>(context, listen: false);
    _groupManagement = Provider.of<GroupManagement>(context, listen: false);

    //Initialize the currentUser locally for this view
    _currentUser = _userManagement!.currentUser;

    initGroupList();

    devtools.log("This is currentUser from user management: ${_currentUser}");

    devtools.log(
        "This is currentUser: group management ${_groupManagement.currentUser}");
  }

  void initGroupList() {
    _groupManagement.fetchAndInitializeGroups(_currentUser!.groupIds);
  }

  //** GROUP FUNCTIONS FOR THE USER TO CREATE GROUPS OR REMOVE GROUPS */

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
    return _currentRole == "Administrator" ||
        _currentRole == "Co-Administrator";
  }

  void _showDeleteConfirmationDialog(Group group) async {
    ;
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirm),
          content: Text(AppLocalizations.of(context)!.questionDeleteGroup),
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
      try {
        bool result =
            await _groupManagement.removeGroup(group, _userManagement!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result
                ? AppLocalizations.of(context)!.groupDeletedSuccessfully
                : "Error deleting group:"),
          ),
        );
        if (result) Navigator.of(context).pop(false);
        setState(() {});
      } catch (error) {
        // Handle the error
      }
    }
  }

  void _leaveGroup(BuildContext context, Group group) async {
    // Check if the current user is the admin of the group
    bool isGroupAdmin = _userManagement!.currentUser!.id == group.ownerId;

    // Display confirmation dialog with custom message for admin
    bool confirm = await _showConfirmationDialog(
      context,
      isGroupAdmin
          ? 'Are you sure you want to dissolve this group?'
          : 'Are you sure you want to leave this group?',
    );

    if (confirm) {
      await _groupManagement.groupService
          .removeUserInGroup(_currentUser!.id, group.id);
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
              // User _groupOwner = await _storeService.getOwnerFromGroup(group);
              User _groupOwner =
                  await _userManagement!.userService.getUserById(group.ownerId);
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
                            group.name
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
    return Consumer2<UserManagement, NotificationManagement>(
      builder: (context, userManagement, notificationManagement, child) {
        // Check if currentUser is null and handle it appropriately
        final currentUser = userManagement.currentUser;
        if (currentUser == null) {
          // Handle the case where the currentUser is null
          return IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Optionally navigate to a default page or show an error
            },
          );
        }

        return StreamBuilder<List<NotificationUser>>(
          stream: notificationManagement.notificationStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  _navigateToShowNotifications(context, currentUser);
                },
              );
            }

            if (snapshot.hasError) {
              // Handle error state
              print('Error fetching notifications: ${snapshot.error}');
              return IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  _navigateToShowNotifications(context, currentUser);
                },
              );
            }

            final notifications = snapshot.data ?? [];
            final unreadNotifications =
                notifications.where((n) => !n.isRead).toList();
            final hasUnreadNotifications = unreadNotifications.isNotEmpty;

            return IconButton(
              icon: Stack(
                alignment: Alignment.topRight,
                children: [
                  Icon(Icons.notifications),
                  if (hasUnreadNotifications)
                    Positioned(
                      right: 0,
                      child:
                          Icon(Icons.brightness_1, size: 10, color: Colors.red),
                    ),
                ],
              ),
              onPressed: () {
                _navigateToShowNotifications(context, currentUser);
                notificationManagement
                    .markNotificationsAsRead(); // Optionally mark as read
              },
            );
          },
        );
      },
    );
  }

  void _navigateToShowNotifications(BuildContext context, User currentUser) {
    Navigator.pushNamed(
      context,
      AppRoutes.showNotifications,
      arguments: currentUser, // Pass the User object as an argument
    );
  }

//**  WE CAN USE STREAMS OR CONSUMER  */

  Widget buildBody(BuildContext context) {
    return StreamBuilder<List<Group>>(
      stream: _groupManagement.groupStream,
      builder: (context, snapshot) {
        // Log snapshot state for better tracking
        devtools.log('StreamBuilder state: ${snapshot.connectionState}');
        devtools.log('StreamBuilder data: ${snapshot.data}');
        devtools.log('StreamBuilder error: ${snapshot.error}');

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          // Show loading indicator only when there's no data and waiting
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If an error occurred in the stream, display an error message
          return _buildErrorWidget('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
          // If the stream has returned an empty list, show a message
          return _buildNoGroupsAvailableWidget();
        } else if (snapshot.hasData) {
          // If the stream has data and it's not empty, show the groups
          List<Group> groups = snapshot.data!;
          return _buildGroupListBody(groups, context);
        } else {
          // Catch-all fallback
          return _buildNoGroupsAvailableWidget();
        }
      },
    );
  }

// Helper widget to show when no groups are available
  Widget _buildNoGroupsAvailableWidget() {
    return Center(
      child: Text(
        'No groups available.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

// Helper widget to show in case of errors
  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Text(
        errorMessage,
        style: TextStyle(fontSize: 16, color: Colors.red),
      ),
    );
  }

// Widget to build the body when groups are available
  Widget _buildGroupListBody(List<Group> groups, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeContainer(context),
        _buildChangeViewRow(context),
        SizedBox(height: 20),
        _buildGroupListView(groups), // Pass groups to ListView builder
      ],
    );
  }

  // Widget buildBody(BuildContext context) {
  //   return Consumer<GroupManagement>(
  //     builder: (context, providerManagement, child) {
  //       final groups = _groupManagement.groups;

  //       if (groups.isEmpty) {
  //         return Center(child: Text('No groups available.'));
  //       }

  //       return Column(
  //         children: [
  //           _buildWelcomeContainer(context),
  //           _buildChangeViewRow(context),
  //           SizedBox(height: 20),
  //           _buildGroupListView(groups),
  //         ],
  //       );
  //     },
  //   );
  // }

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
        User _groupOwner =
            await _userManagement!.userService.getUserById(group.ownerId);
        showProfileAlertDialog(context, group, _groupOwner);
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
                group.name,
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
                  Group? groupFetched;

                  if (_groupManagement.currentGroup != null) {
                    groupFetched = _groupManagement.currentGroup!;
                  } else {
                    _groupManagement.currentGroup = group;
                    groupFetched = _groupManagement.currentGroup;
                  }
                  Navigator.pushNamed(
                    context,
                    AppRoutes.groupCalendar,
                    arguments: groupFetched,
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
                      var selectedGroup = await _groupManagement.groupService
                          .getGroupById(group.id);
                      List<User> users = [];
                      for (var userID in selectedGroup.userIds) {
                        User user = await _userManagement!.userService
                            .getUserById(userID);
                        users.add(user);
                      }
                      // await _storeService.getGroupFromId(group.id);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.editGroupData,
                        arguments:
                            EditGroupData(group: selectedGroup, users: users),
                      );
                    },
                    child: Text(AppLocalizations.of(context)!.edit),
                  ),
                  TextButton(
                    onPressed: () {
                      // Remove group logic here
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