import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/controllers/create_group_controller.dart';
import 'package:first_project/c-frontend/b-group-section/screens/create-group/search-bar/widgets/create_group_search_bar.dart';
import 'package:first_project/f-themes/themes/theme_colors.dart';
import 'package:first_project/f-themes/utilities/view-item-styles/button/button_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../../a-models/group_model/group/group.dart';
import '../../../../a-models/user_model/user.dart';

class AddUserButtonDialog extends StatelessWidget {
  final User? currentUser;
  final Group? group;
  final GroupController controller;

  const AddUserButtonDialog({
    Key? key,
    required this.currentUser,
    required this.group,
    required this.controller,
  }) : super(key: key);

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final appLocalizations = AppLocalizations.of(context)!;
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    appLocalizations.addPplGroup,
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
                  group: group,
                  user: currentUser,
                  controller: controller,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(appLocalizations.close),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          appLocalizations.addPplGroup,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? ThemeColors.getTextColor(context).withOpacity(0.7)
                : Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ButtonStyles.buttonWithIcon(
          iconData: Icons.person_add_alt_1,
          label: appLocalizations.addUser,
          style: ButtonStyles.saucyButtonStyle(
            defaultBackgroundColor:
                ThemeColors.getButtonBackgroundColor(context),
            pressedBackgroundColor:
                ThemeColors.getContainerBackgroundColor(context),
            textColor: ThemeColors.getButtonTextColor(context),
            borderColor: ThemeColors.getTextColor(context),
          ),
          onPressed: () => _openDialog(context),
        ),
      ],
    );
  }
}
