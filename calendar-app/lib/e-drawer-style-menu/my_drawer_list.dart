import 'package:first_project/b-backend/auth/auth_database/auth/auth_provider.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import '../utilities/enums/routes/appRoutes.dart';

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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (menuItems.isNotEmpty) ...[
        const SizedBox(height: 15.0),
        menuItem(context, menuItems[0]['section'], menuItems[0]['title'],
            menuItems[0]['icon'], menuItems[0]['isSelected']),
        for (int i = 1; i < menuItems.length; i++)
          menuItem(context, menuItems[i]['section'], menuItems[i]['title'],
              menuItems[i]['icon'], menuItems[i]['isSelected']),
      ],
    ],
  );
}

Widget menuItem(BuildContext context, DrawerSections section, String name,
    IconData iconData, bool selected) {
  Color textColor = ThemeColors.getTextColor(context);
  String translatedName = _getTranslatedTitle(context, name);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0, left: 15),
                child: Icon(iconData, size: 20, color: textColor),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 35.0),
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
    default:
      return key;
  }
}

//* LOGOUT HANDLER */
bool _loggingOut = false;

Future<void> _handleLogout(BuildContext context) async {
  if (!_loggingOut) {
    _loggingOut = true;

    try {
      final shouldLogout = await showLogOutDialog(context);
      if (shouldLogout) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logOut();

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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
