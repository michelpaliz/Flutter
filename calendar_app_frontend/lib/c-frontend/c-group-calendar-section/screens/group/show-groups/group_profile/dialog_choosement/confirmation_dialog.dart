import 'package:hexora/f-themes/themes/theme_colors.dart';
import 'package:flutter/material.dart';

Future<bool> showConfirmationDialog(BuildContext context, String message) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: ThemeColors.getTextColor(context)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Confirm',
              style: TextStyle(color: ThemeColors.getTextColor(context)),
            ),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
