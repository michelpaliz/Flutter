import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../a-models/user_model/user.dart';
import '../../../../c-frontend/b-group-section/screens/create-group/create_group_search_bar.dart';
import 'group_controller.dart';

class GroupAddUserButton extends StatelessWidget {
  final GroupController controller;

  const GroupAddUserButton({super.key, required this.controller});

  void _openAddUserDialog(BuildContext context, User? currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.addNewUser,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: CreateGroupSearchBar(
                  onDataChanged: controller.onDataChanged,
                  user: currentUser,
                  group: null,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(AppLocalizations.of(context)!.close),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.addPplGroup,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(width: 15),
        TextButton(
          onPressed: () => _openAddUserDialog(context, controller.currentUser),
          child: Text(AppLocalizations.of(context)!.addUser),
        ),
      ],
    );
  }
}
