import 'package:first_project/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:flutter/material.dart';

class GroupNameField extends StatelessWidget {
  final String groupName;
  final ValueChanged<String> onNameChange;

  const GroupNameField({
    required this.groupName,
    required this.onNameChange,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller =
        TextEditingController(text: groupName);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomEditableTextField(
        controller: _controller,
        labelText: 'Group Name',// TODO: IMPLEMENT TRANSLATION
        maxLength: 25,
        prefixIcon: Icons.group, // Nice little group icon
      ),
    );
  }
}
