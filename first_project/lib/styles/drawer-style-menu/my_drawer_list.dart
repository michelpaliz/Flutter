
import 'package:first_project/backend/firebase_%20services/auth/logic_backend/auth_service.dart';
import 'package:first_project/styles/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import '../../enums/routes/appRoutes.dart';

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

//* UI FOR THE DRAWER LIST */

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
  Color textColor = ThemeColors.getTextColor(context);

  String translatedName = _getTranslatedTitle(context, name);

  return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.0),
    child: InkWell(
      onTap: () {
        switch (section) {
          case DrawerSections.dashboard:
            Navigator.pushNamed(context, AppRoutes.showGroups);
            break;
          case DrawerSections.notes_view:
            Navigator.pushNamed(context, AppRoutes.userCalendar);
            break;
          case DrawerSections.settings:
            Navigator.pushNamed(context, AppRoutes.settings);
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
                  color: textColor,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(left: 35.0), // Adjust the desired spacing
                child: Text(
                  translatedName,
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _getTranslatedTitle(BuildContext context, String key) {
  final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

  switch (key) {
    case 'Groups':
      return appLocalizations.groups;
    case 'Calendar':
      return appLocalizations.calendar;
    case 'Settings':
      return appLocalizations.settings;
    case 'Log out':
      return appLocalizations.logout;
    // Add more cases as needed
    default:
      return key; // Default to the original key if not found
  }
}

//*LOG OUT LOGIC */
// Add this variable to your class to track logout state
bool _loggingOut = false;

Future<void> _handleLogout(BuildContext context) async {
  if (!_loggingOut) {
    _loggingOut = true;

    try {
      final shouldLogout = await showLogOutDialog(context);
      if (shouldLogout) {
        // Call logout method from ProviderManagement
        // final provider =
        //     Provider.of<ProviderManagement>(context, listen: false);
        // provider.logout();

        // Log out from the AuthService
        await AuthService.firebase().logOut();

        // Navigate to the login screen and remove all other routes
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.loginRoute, (_) => false);
      }
    } finally {
      _loggingOut = false;
    }
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
