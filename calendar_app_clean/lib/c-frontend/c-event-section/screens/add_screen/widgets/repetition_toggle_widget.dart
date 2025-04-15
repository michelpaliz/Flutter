import 'package:flutter/material.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
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
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(width: 70),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: 2 * toggleWidth,
            height: 40.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: isRepetitive ? Colors.green : Colors.grey,
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Text(
                  isRepetitive ? 'ON' : 'OFF',
                  style: TextStyle(
                      color: isRepetitive
                          ? Color.fromARGB(255, 28, 86, 120)
                          : Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
