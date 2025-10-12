import 'package:flutter/material.dart';
import 'package:hexora/a-models/group_model/group/group.dart';
import 'package:hexora/b-backend/group_mng_flow/event/domain/event_domain.dart';
import 'package:hexora/c-frontend/routes/appRoutes.dart';
import 'package:hexora/l10n/app_localizations.dart';

class AppBarManager {
  AppBar buildAppBar(
    BuildContext context,
    EventDomain eventDomain,
    Group group,
  ) {
    final loc = AppLocalizations.of(context)!;

    return AppBar(
      title: Text(loc.calendar.toUpperCase()),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.groupSettings,
              arguments: group,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () async {
            try {
              await eventDomain.manualRefresh(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.refreshSuccess)),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${loc.refreshFailed}: $e')),
              );
            }
          },
        ),
      ],
    );
  }
}
