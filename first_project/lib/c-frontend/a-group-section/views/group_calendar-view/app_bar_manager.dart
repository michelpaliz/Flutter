import 'package:first_project/a-models/group.dart';
import 'package:first_project/enums/routes/appRoutes.dart';
import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class AppBarManager {
  AppBar buildAppBar(BuildContext context, Function reloadData, Group group) {
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
          onPressed: () {
            reloadData();
          },
        ),
      ],
    );
  }
}

