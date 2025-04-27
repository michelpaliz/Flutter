// lib/c-frontend/b-group-section/screens/edit-group/edit_group_header.dart
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/group/group_description_field.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/group/group_image_field.dart';
import 'package:first_project/c-frontend/c-event-section/screens/edit_screen/widgets/group/group_name_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditGroupHeader extends StatelessWidget {
  final String imageURL;
  final XFile? selectedImage;
  final VoidCallback onPickImage;
  final String groupName;
  final void Function(String) onNameChange;
  final TextEditingController descriptionController;

  const EditGroupHeader({
    Key? key,
    required this.imageURL,
    this.selectedImage,
    required this.onPickImage,
    required this.groupName,
    required this.onNameChange,
    required this.descriptionController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GroupImageSection(
          imageURL: imageURL,
          selectedImage: selectedImage,
          onPickImage: onPickImage,
        ),
        const SizedBox(height: 15),
        GroupNameField(
          groupName: groupName,
          onNameChange: onNameChange,
        ),
        GroupDescriptionField(
          descriptionController: descriptionController,
        ),
      ],
    );
  }
}
