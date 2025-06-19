import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:first_project/a-models/group_model/event_appointment/appointment/custom_day_week.dart';
import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';

import 'package:first_project/c-frontend/c-event-section/screens/repetition_dialog/widgets/frequency_selector.dart';
import 'package:first_project/c-frontend/c-event-section/screens/repetition_dialog/widgets/repeat_every_row.dart';
import 'package:first_project/c-frontend/c-event-section/screens/repetition_dialog/widgets/weekly_day_selector.dart';
import 'package:first_project/c-frontend/c-event-section/screens/repetition_dialog/widgets/until_date_picker.dart';
import 'package:first_project/c-frontend/c-event-section/screens/repetition_dialog/utils/repetition_rule_helper.dart';

class RepetitionDialog extends StatefulWidget {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final RecurrenceRule? initialRecurrenceRule;

  const RepetitionDialog({
    super.key,
    required this.selectedStartDate,
    required this.selectedEndDate,
    this.initialRecurrenceRule,
  });

  @override
  _RepetitionDialogState createState() => _RepetitionDialogState();
}

class _RepetitionDialogState extends State<RepetitionDialog> {
  String selectedFrequency = 'Daily';
  int? repeatInterval = 0;
  int? dayOfMonth;
  int? selectedMonth;
  bool isForever = false;
  DateTime? untilDate;
  Set<CustomDayOfWeek> selectedDays = {};
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;
  bool isRepeated = false;
  String? validationError;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.selectedStartDate;
    _selectedEndDate = widget.selectedEndDate;
    _fillVariablesFromInitialRecurrenceRule(widget.initialRecurrenceRule);
  }

  void _fillVariablesFromInitialRecurrenceRule(RecurrenceRule? rule) {
    if (rule != null) {
      selectedFrequency = rule.name;
      repeatInterval = rule.repeatInterval;
      dayOfMonth = rule.dayOfMonth;
      selectedMonth = rule.month;
      untilDate = rule.untilDate;
      isForever = rule.untilDate == null;
      selectedDays = Set<CustomDayOfWeek>.from(rule.daysOfWeek ?? []);
    }
  }

  void _goBackToParentView(
    RecurrenceRule? recurrenceRule,
    bool? isRepetitiveUpdated,
  ) {
    setState(() {
      isRepeated = isRepetitiveUpdated ?? false;
    });
    Navigator.of(context).pop([recurrenceRule, isRepeated]);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          AppLocalizations.of(context)!.selectRepetition.toUpperCase(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. FREQUENCY SELECTOR
            RepeatFrequencySelector(
              selectedFrequency: selectedFrequency,
              onSelectFrequency: (frequency) {
                setState(() {
                  selectedFrequency = frequency;
                });
              },
            ),

            const SizedBox(height: 12),

            /// 2. REPEAT EVERY ROW
            RepeatEveryRow(
              selectedFrequency: selectedFrequency,
              repeatInterval: repeatInterval ?? 1,
              selectedDays: selectedDays.toList(),
              selectedStartDate: _selectedStartDate,
              onIntervalChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    repeatInterval = value;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            /// 3. WEEKLY DAY SELECTOR
            if (selectedFrequency == 'Weekly')
              WeeklyDaySelector(
                selectedDays: selectedDays,
                onDayToggle: (day, isSelected) {
                  setState(() {
                    if (isSelected) {
                      selectedDays.add(day);
                    } else {
                      selectedDays.remove(day);
                    }
                  });
                },
              ),

            const SizedBox(height: 12),

            /// 4. UNTIL DATE PICKER
            UntilDatePicker(
              isForever: isForever,
              untilDate: untilDate,
              onForeverChanged: (newValue) {
                setState(() {
                  isForever = newValue;
                  if (isForever) untilDate = null;
                });
              },
              onDateSelected: (date) {
                setState(() {
                  untilDate = date;
                });
              },
            ),

            /// 5. VALIDATION ERROR
            if (validationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  validationError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            _goBackToParentView(null, false);
          },
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final result = validateAndCreateRecurrenceRule(
              context: context,
              frequency: selectedFrequency,
              repeatInterval: repeatInterval,
              isForever: isForever,
              untilDate: untilDate,
              selectedStartDate: _selectedStartDate,
              selectedEndDate: _selectedEndDate,
              selectedDays: selectedDays,
              dayOfMonth: dayOfMonth,
              selectedMonth: selectedMonth,
            );

            if (result.error != null) {
              setState(() {
                validationError = result.error;
              });
            } else {
              _goBackToParentView(result.rule, true);
            }
          },
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      ],
    );
  }
}
