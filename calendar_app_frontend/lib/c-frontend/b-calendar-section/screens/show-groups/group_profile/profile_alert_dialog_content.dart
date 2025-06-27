import 'package:calendar_app_frontend/a-models/group_model/group/group.dart';
import 'package:calendar_app_frontend/c-frontend/routes/appRoutes.dart';
import 'package:calendar_app_frontend/d-stateManagement/group/group_management.dart';
import 'package:calendar_app_frontend/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:calendar_app_frontend/f-themes/utilities/utilities.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

Widget buildProfileDialogContent(BuildContext context, Group group) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 30,
        backgroundImage: Utilities.buildProfileImage(group.photo),
      ),
      const SizedBox(height: 8),
      Text(
        group.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      const SizedBox(height: 8),
      Text(
        '${group.createdTime.year}-${group.createdTime.month}-${group.createdTime.day}',
      ),
      const SizedBox(height: 15),
      TextButton(
        onPressed: () {
          final groupManagement = Provider.of<GroupManagement>(
            context,
            listen: false,
          );
          groupManagement.currentGroup = group;
          Navigator.pushNamed(
            context,
            AppRoutes.groupCalendar,
            arguments: group,
          );
        },
        style: ButtonStyles.saucyButtonStyle(
          defaultBackgroundColor: const Color.fromARGB(255, 229, 117, 151),
          pressedBackgroundColor: const Color.fromARGB(255, 227, 62, 98),
          textColor: const Color.fromARGB(255, 26, 26, 26),
          borderColor: const Color.fromARGB(255, 53, 10, 7),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month_rounded),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.goToCalendar),
          ],
        ),
      ),
    ],
  );
}
