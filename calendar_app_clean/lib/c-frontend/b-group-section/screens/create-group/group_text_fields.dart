import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'group_controller.dart';

class GroupTextFields extends StatelessWidget {
  final GroupController controller;

  const GroupTextFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const int TITLE_MAX_LENGTH = 25;
    const int DESCRIPTION_MAX_LENGTH = 100;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              if (value.length <= TITLE_MAX_LENGTH) {
                controller.groupName = value;
              }
            },
            inputFormatters: [
              LengthLimitingTextInputFormatter(TITLE_MAX_LENGTH),
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!
                  .textFieldGroupName(TITLE_MAX_LENGTH),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: (value) {
              controller.groupDescription = value;
            },
            maxLines: null,
            inputFormatters: [
              LengthLimitingTextInputFormatter(DESCRIPTION_MAX_LENGTH),
            ],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!
                  .textFieldDescription(DESCRIPTION_MAX_LENGTH),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
