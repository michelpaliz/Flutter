import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupDescriptionField extends StatelessWidget {
  final TextEditingController descriptionController;

  const GroupDescriptionField({
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: descriptionController,
        maxLines: 5,
        inputFormatters: [LengthLimitingTextInputFormatter(100)],
        decoration: InputDecoration(
          labelText: 'Group Description',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
