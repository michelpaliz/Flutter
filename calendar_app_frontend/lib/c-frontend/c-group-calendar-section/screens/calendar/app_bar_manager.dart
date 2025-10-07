import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/core/event/domain/event_domain.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/l10n/app_localizations.dart';

class AppBarManager {
  AppBar buildAppBar(
    BuildContext context,
    EventDomain eventDataManager,
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
