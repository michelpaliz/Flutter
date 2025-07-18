import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/edit-group/widgets/form/group_description_field.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/edit-group/widgets/form/group_image_section.dart';
import 'package:calendar_app_frontend/c-frontend/b-calendar-section/screens/group-screen/edit-group/widgets/form/group_name_field.dart';

import 'package:calendar_app_frontend/f-themes/shape/solid/solid_header.dart';
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
    return Stack(
      children: [
        const SolidHeader(height: 360), // background color behind everything
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GroupImageSection(
                imageURL: imageURL,
                selectedImage: selectedImage,
                onPickImage: onPickImage,
              ),
              const SizedBox(height: 15),
              GroupNameField(groupName: groupName, onNameChange: onNameChange),
              GroupDescriptionField(
                descriptionController: descriptionController,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
