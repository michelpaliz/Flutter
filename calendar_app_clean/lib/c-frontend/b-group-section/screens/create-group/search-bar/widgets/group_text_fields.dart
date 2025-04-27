import 'package:first_project/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controllers/create_group_controller.dart';

class GroupTextFields extends StatelessWidget {
  final GroupController controller;

  const GroupTextFields({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const int TITLE_MAX_LENGTH = 25;
    const int DESCRIPTION_MAX_LENGTH = 100;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomEditableTextField(
            controller: TextEditingController(text: controller.groupName),
            labelText: AppLocalizations.of(context)!
                .textFieldGroupName(TITLE_MAX_LENGTH),
            maxLength: TITLE_MAX_LENGTH,
            isMultiline: false,
            prefixIcon: Icons.group, // Optional icon
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomEditableTextField(
            controller:
                TextEditingController(text: controller.groupDescription),
            labelText: AppLocalizations.of(context)!
                .textFieldDescription(DESCRIPTION_MAX_LENGTH),
            maxLength: DESCRIPTION_MAX_LENGTH,
            isMultiline: true,
            prefixIcon: Icons.description, // Optional icon
          ),
        ),
      ],
    );
  }
}
