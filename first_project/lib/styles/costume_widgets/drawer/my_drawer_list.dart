import 'package:flutter/material.dart';

import '../../../enums/routes/routes.dart';
import '../../../services/auth/implements/auth_service.dart';

//* GLOBAL VARIABLES */

enum DrawerSections { dashboard, notes_view, settings, log_out }

List<Map<String, dynamic>> menuItems = [
  {
    'section': DrawerSections.dashboard,
    'title': 'Groups',
    'icon': Icons.group,
    'isSelected': true,
  },
  {
    'section': DrawerSections.notes_view,
    'title': 'Calendar',
    'icon': Icons.calendar_month,
    'isSelected': false,
  },
  {
    'section': DrawerSections.settings,
    'title': 'Settings',
    'icon': Icons.settings,
    'isSelected': false,
  },
  {
    'section': DrawerSections.log_out,
    'title': 'Log out',
    'icon': Icons.logout,
    'isSelected': false,
  },
];

//* UI FOR THE DRAWERLIST */

Widget MyDrawerList(BuildContext context) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (menuItems.isNotEmpty) ...[
          SizedBox(height: 15.0), // Adjust the desired spacing
          menuItem(context, menuItems[0]['section'], menuItems[0]['title'],
              menuItems[0]['icon'], menuItems[0]['isSelected']),
          for (int i = 1; i < menuItems.length; i++)
            menuItem(context, menuItems[i]['section'], menuItems[i]['title'],
                menuItems[i]['icon'], menuItems[i]['isSelected']),
        ],
      ],
    ),
  );
}

Widget menuItem(BuildContext context, DrawerSections section, String name,
    IconData iconData, bool selected) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: InkWell(
      onTap: () {
        switch (section) {
          case DrawerSections.dashboard:
            Navigator.pushNamed(context, showGroups);
            break;
          case DrawerSections.notes_view:
            Navigator.pushNamed(context, userCalendar);
            break;
          case DrawerSections.settings:
            Navigator.pushNamed(context, settings);
            break;
          case DrawerSections.log_out:
            _handleLogout(context);
            break;
        }
      },
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Padding(
                padding: EdgeInsets.only(
                    right: 8.0, left: 15), // Adjust the desired spacing
                child: Icon(
                  iconData,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(left: 35.0), // Adjust the desired spacing
                child: Text(
                  name,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//*LOG OUT LOGIC */

Future<void> _handleLogout(BuildContext context) async {
  final shouldLogout = await showLogOutDialog(context);
  if (shouldLogout) {
    await AuthService.firebase().logOut();
    Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_) => false);
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
