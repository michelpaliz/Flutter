import 'package:flutter/material.dart';
import 'package:first_project/a-models/group_model/event-appointment/appointment/recurrence_rule.dart';
import 'package:first_project/f-themes/widgets/repetition_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RepetitionToggle extends StatelessWidget {
  final bool isRepetitive;
  final double toggleWidth;
  final DateTime startDate;
  final DateTime endDate;
  final RecurrenceRule? initialRule;
  final Function(bool, RecurrenceRule?) onToggleChanged;

  const RepetitionToggle({
    Key? key,
    required this.isRepetitive,
    required this.toggleWidth,
    required this.startDate,
    required this.endDate,
    required this.initialRule,
    required this.onToggleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocalizations.of(context)!.repetitionDetails,
          style: const TextStyle(fontSize: 15),
        ),
        const SizedBox(width: 70),
        GestureDetector(
          onTap: () async {
            final result = await showDialog(
              context: context,
              builder: (_) => RepetitionDialog(
                selectedStartDate: startDate,
                selectedEndDate: endDate,
                initialRecurrenceRule: initialRule,
              ),
            );
            if (result != null && result.isNotEmpty) {
              onToggleChanged(result[1], result[0]);
            }
          },
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
                child: isRepetitive
                    ? const Text('ON', style: TextStyle(color: Color.fromARGB(255, 28, 86, 120)))
                    : const Text('OFF', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
