import 'package:first_project/f-themes/utilities/view-item-styles/text_field/flexible/custom_editable_text_field.dart';
import 'package:flutter/material.dart';

class GroupDescriptionField extends StatelessWidget {
  final TextEditingController descriptionController;

  const GroupDescriptionField({
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomEditableTextField(
        controller: descriptionController,
        labelText: 'Group Description',
        maxLength: 100,
        isMultiline: true,
        prefixIcon: Icons.description, // Optional nice touch!
      ),
    );
  }
}
