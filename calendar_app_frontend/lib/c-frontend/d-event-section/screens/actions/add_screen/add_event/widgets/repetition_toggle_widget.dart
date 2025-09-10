import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class RepetitionToggleWidget extends StatelessWidget {
  final bool isRepetitive;
  final double toggleWidth;
  final VoidCallback onTap;

  const RepetitionToggleWidget({
    Key? key,
    required this.isRepetitive,
    required this.toggleWidth,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          loc.repeatEventLabel,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent, // for InkWell splash
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: toggleWidth,
              height: 30,
              decoration: BoxDecoration(
                color: isRepetitive
                    ? theme.colorScheme.primary // ✅ from theme
                    : theme.colorScheme.surfaceVariant, // ✅ from theme
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: Text(
                isRepetitive ? loc.repeatYes : loc.repeatNo,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary, // ✅ readable contrast
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
