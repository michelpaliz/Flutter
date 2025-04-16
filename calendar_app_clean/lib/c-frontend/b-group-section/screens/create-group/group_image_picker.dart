import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'group_controller.dart';

class GroupImagePicker extends StatelessWidget {
  final GroupController controller;

  const GroupImagePicker({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await controller.pickImage();
          },
          child: CircleAvatar(
            radius: 50,
            backgroundColor:
                controller.selectedImage != null ? Colors.transparent : null,
            backgroundImage: controller.selectedImage != null
                ? FileImage(File(controller.selectedImage!.path))
                : null,
            child: controller.selectedImage == null
                ? const Icon(
                    Icons.add_a_photo,
                    size: 50,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context)!.putGroupImage,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
