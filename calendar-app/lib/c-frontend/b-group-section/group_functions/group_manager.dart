import 'package:first_project/a-models/model/group_data/group/group.dart';
import 'package:first_project/b-backend/database_conection/node_services/group_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupManager {
  // Static method for performing group update
  static void performGroupUpdate(
    BuildContext context, 
    GroupService groupService, 
    Group group
  ) async {
    if (group.name.isNotEmpty && group.description.isNotEmpty) {
      // Update the group using the GroupService
      bool groupUpdated = await groupService.updateGroup(group);

      if (groupUpdated) {
        // Group update was successful, show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.groupEdited),
          ),
        );
      } else {
        // Group update failed, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToEditGroup),
          ),
        );
      }

      print('Group name: ${group.name}');
      print('Group description: ${group.description}');
    } else {
      // Display an error message if required fields are missing
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(AppLocalizations.of(context)!.requiredTextFields),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
