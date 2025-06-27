import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class RepetitionToggleWidget extends StatelessWidget {
  final bool isRepetitive;
  final double toggleWidth;
  final VoidCallback onTap;

  const RepetitionToggleWidget({
    required this.isRepetitive,
    required this.toggleWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.repetitionDetails,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(width: 70),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 2 * toggleWidth,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: isRepetitive ? Colors.green : Colors.grey,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  isRepetitive ? 'ON' : 'OFF',
                  key: ValueKey(isRepetitive), // 👈 Important for animation
                  style: TextStyle(
                    color: isRepetitive
                        ? const Color.fromARGB(255, 28, 86, 120)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
