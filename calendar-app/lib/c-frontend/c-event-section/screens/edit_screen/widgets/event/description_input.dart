import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DescriptionInput extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionInput({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.description(100),
      ),
      maxLength: 100,
    );
  }
}
