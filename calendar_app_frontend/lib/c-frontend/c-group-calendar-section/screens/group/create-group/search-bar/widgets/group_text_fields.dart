import 'package:hexora/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../controllers/group_controller.dart';

// lib/.../widgets/group_text_fields.dart
// …imports unchanged…

class GroupTextFields extends StatelessWidget {
  final GroupController controller;
  const GroupTextFields({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const titleMax = 25;
    const descMax = 100;

    final loc = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    InputDecoration deco(IconData icon) => InputDecoration(
          prefixIcon:
              Icon(icon, color: scheme.onPrimaryContainer.withOpacity(.9)),
          filled: true,
          fillColor: scheme.primary.withOpacity(.12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          counterStyle: TextStyle(color: scheme.onSurfaceVariant),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(context, loc.groupNameLabel),
        TextField(
          controller: controller.nameController,
          maxLength: titleMax,
          textInputAction: TextInputAction.next,
          decoration: deco(Icons.group),
        ),
        const SizedBox(height: 8),
        _label(context, loc.descriptionLabel),
        TextField(
          controller: controller.descriptionController,
          maxLength: descMax,
          maxLines: 3,
          decoration: deco(Icons.description),
        ),
      ],
    );
  }

  Widget _label(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            letterSpacing: .5,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
}
