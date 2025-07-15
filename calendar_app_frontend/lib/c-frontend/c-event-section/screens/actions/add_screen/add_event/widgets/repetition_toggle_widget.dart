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

    return Row(
      children: [
        Text(
          loc.repeatEventLabel,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onTap,
          child: Container(
            width: toggleWidth,
            height: 30,
            decoration: BoxDecoration(
              color: isRepetitive ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              isRepetitive ? loc.repeatYes : loc.repeatNo,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
