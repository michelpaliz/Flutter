import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupNameField extends StatelessWidget {
  final String groupName;
  final ValueChanged<String> onNameChange;

  const GroupNameField({
    required this.groupName,
    required this.onNameChange,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: TextEditingController(text: groupName),
        onChanged: (value) {
          if (value.length <= 25) {
            onNameChange(value);
          }
        },
        inputFormatters: [LengthLimitingTextInputFormatter(25)],
        decoration: InputDecoration(
          labelText: 'Group Name',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
