// lib/.../create-group/widgets/group_image_picker.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/create_group_controller.dart'; // adjust path if needed

class GroupImagePicker extends StatelessWidget {
  const GroupImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupController>(
      builder: (context, controller, _) {
        final hasImage = controller.selectedImage != null;

        return InkWell(
          onTap: controller.pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(controller.selectedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo, size: 36),
                      SizedBox(height: 8),
                      Text('Add photo'),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
