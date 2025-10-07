import 'package:hexora/b-backend/login_user/auth/auth_database/auth_provider.dart';
import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../c-frontend/routes/appRoutes.dart';

//* GLOBAL VARIABLES */

enum DrawerSections { calendar, settings, logOut }

/// We only need section & icon now; title comes from localizations.
final List<Map<String, dynamic>> menuItems = [
  {
    'section': DrawerSections.calendar,
    'icon': Icons.calendar_month,
    'isSelected': false,
  },
  {
    'section': DrawerSections.settings,
    'icon': Icons.settings,
    'isSelected': false,
  },
  {'section': DrawerSections.logOut, 'icon': Icons.logout, 'isSelected': false},
];

//* UI FOR THE DRAWER LIST */

Widget MyDrawerList(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 15.0),
      for (var item in menuItems)
        menuItem(
          context,
          item['section'] as DrawerSections,
          item['icon'] as IconData,
          item['isSelected'] as bool,
        ),
    ],
  );
}

Widget menuItem(
  BuildContext context,
  DrawerSections section,
  IconData iconData,
  bool selected,
) {
  final textColor = ThemeColors.getTextColor(context);
  final title = _getTranslatedTitle(context, section);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: InkWell(
      onTap: () {
        switch (section) {
          case DrawerSections.calendar:
            Navigator.pushNamed(context, AppRoutes.homePage);
            break;
          case DrawerSections.settings:
            Navigator.pushNamed(context, AppRoutes.settings);
            break;
          case DrawerSections.logOut:
            _handleLogout(context);
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0, left: 15),
              child: Icon(iconData, size: 20, color: textColor),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 35.0),
                child: Text(
                  title,
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

String _getTranslatedTitle(BuildContext context, DrawerSections section) {
  final loc = AppLocalizations.of(context)!;
  switch (section) {
    case DrawerSections.calendar:
      return loc.calendar;
    case DrawerSections.settings:
      return loc.settings;
    case DrawerSections.logOut:
      return loc.logout;
  }
}

//* LOGOUT HANDLER */
bool _loggingOut = false;

Future<void> _handleLogout(BuildContext context) async {
  if (_loggingOut) return;
  _loggingOut = true;
  try {
    final shouldLogout = await showLogOutDialog(context);
    if (shouldLogout) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logOut();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.loginRoute, (_) => false);
    }
  } finally {
    _loggingOut = false;
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  final loc = AppLocalizations.of(context)!;
  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(loc.logout),
        content: Text(loc.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.logout),
          ),
        ],
      );
    },
  ).then((v) => v ?? false);
}
