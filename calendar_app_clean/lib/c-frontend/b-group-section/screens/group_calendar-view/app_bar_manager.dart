import 'package:first_project/a-models/group_model/group/group.dart';
import 'package:first_project/c-frontend/routes/appRoutes.dart';
import 'package:first_project/d-stateManagement/event/event_data_manager.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class AppBarManager {
  AppBar buildAppBar(
      BuildContext context, EventDataManager eventDataManager, Group group) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.calendar.toUpperCase()),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.groupSettings,
              arguments: group,
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () async {
            try {
              await eventDataManager.manualRefresh();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calendar refreshed')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Refresh failed: ${e.toString()}')),
              );
            }
          },
        ),
      ],
    );
  }
}
