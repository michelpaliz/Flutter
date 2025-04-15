import 'dart:developer' as devtools show log;

import 'package:first_project/c-frontend/b-group-section/screens/show-groups/group_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/a-models/user_model/user.dart';
import 'package:first_project/d-stateManagement/group_management.dart';
import 'package:first_project/d-stateManagement/user_management.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget buildBody(
  BuildContext context,
  Axis scrollDirection,
  VoidCallback toggleScrollDirection,
  User? currentUser,
  UserManagement userManagement,
  GroupManagement groupManagement,
  void Function(String?) updateRole,
) {
  return StreamBuilder<List<Group>>(
    stream: groupManagement.groupStream,
    builder: (context, snapshot) {
      devtools.log('StreamBuilder state: ${snapshot.connectionState}');
      devtools.log('StreamBuilder data: ${snapshot.data}');
      devtools.log('StreamBuilder error: ${snapshot.error}');

      if (snapshot.connectionState == ConnectionState.waiting &&
          !snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return _buildErrorWidget('Error: ${snapshot.error}');
      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
        return _buildNoGroupsAvailableWidget();
      } else if (snapshot.hasData) {
        List<Group> groups = snapshot.data!;
        return _buildGroupListBody(
          context,
          groups,
          scrollDirection,
          toggleScrollDirection,
          currentUser,
          userManagement,
          groupManagement,
          updateRole,
        );
      } else {
        return _buildNoGroupsAvailableWidget();
      }
    },
  );
}

Widget _buildNoGroupsAvailableWidget() {
  return Center(
    child: Text(
      'No groups available.',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    ),
  );
}

Widget _buildErrorWidget(String errorMessage) {
  return Center(
    child: Text(
      errorMessage,
      style: TextStyle(fontSize: 16, color: Colors.red),
    ),
  );
}

Widget _buildGroupListBody(
  BuildContext context,
  List<Group> groups,
  Axis scrollDirection,
  VoidCallback toggleScrollDirection,
  User? currentUser,
  UserManagement userManagement,
  GroupManagement groupManagement,
  void Function(String?) updateRole,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildWelcomeContainer(context, currentUser),
      _buildChangeViewRow(toggleScrollDirection, context),
      SizedBox(height: 20),
      _buildGroupListView(
        context,
        groups,
        scrollDirection,
        currentUser,
        userManagement,
        groupManagement,
        updateRole,
      ),
    ],
  );
}

Widget _buildWelcomeContainer(BuildContext context, User? currentUser) {
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
          currentUser != null
              ? currentUser.name[0].toUpperCase() + currentUser.name.substring(1)
              : 'User',
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

Widget _buildChangeViewRow(VoidCallback toggleScrollDirection, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        AppLocalizations.of(context)!.changeView,
        style: TextStyle(fontSize: 12),
      ),
      SizedBox(width: 10),
      GestureDetector(
        onTap: toggleScrollDirection,
        child: Icon(Icons.dashboard),
      ),
    ],
  );
}

Widget _buildGroupListView(
  BuildContext context,
  List<Group> groups,
  Axis scrollDirection,
  User? currentUser,
  UserManagement userManagement,
  GroupManagement groupManagement,
  void Function(String?) updateRole,
) {
  return SizedBox(
    height: scrollDirection == Axis.vertical ? 500 : 130,
    child: ListView.separated(
      separatorBuilder: (context, index) => SizedBox(height: 10),
      scrollDirection: scrollDirection,
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return buildGroupCard(
          context,
          groups[index],
          currentUser,
          userManagement,
          groupManagement,
          updateRole,
        );
      },
    ),
  );
}
