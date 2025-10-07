// lib/.../widgets/group_image_picker.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hexora/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../../b-backend/core/group/view_model/group_view_model.dart';

class GroupImagePicker extends StatelessWidget {
  const GroupImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Consumer<GroupViewModel>(
      builder: (context, controller, _) {
        final hasImage = controller.selectedImage != null;
        final size =
            MediaQuery.of(context).size.width.clamp(280.0, 420.0) * .38;

        return Center(
          child: InkWell(
            onTap: controller.pickImage,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: size,
              width: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surfaceVariant,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: hasImage
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(controller.selectedImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 8),
                        Text(
                          loc.addPhoto, // <— localized
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
