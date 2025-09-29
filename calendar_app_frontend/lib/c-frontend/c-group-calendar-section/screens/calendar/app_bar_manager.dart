import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/d-stateManagement/event/event_data_manager.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class AppBarManager {
  AppBar buildAppBar(
    BuildContext context,
    EventDataManager eventDataManager,
    Group group,
  ) {
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
              await eventDataManager.manualRefresh(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Calendar refreshed')));
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
