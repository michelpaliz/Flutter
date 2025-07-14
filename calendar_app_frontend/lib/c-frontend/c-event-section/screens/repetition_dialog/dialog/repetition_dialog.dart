import 'package:calendar_app_frontend/a-models/group_model/recurrenceRule/recurrence_rule/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/a-models/group_model/recurrenceRule/utils_recurrence_rule/custom_day_week.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/repetition_dialog/utils/frequency_selector.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/repetition_dialog/utils/repetition_rule_helper.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/repetition_dialog/widgets/repeat_every_row.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/repetition_dialog/widgets/until_date_picker.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/screens/repetition_dialog/widgets/weekly_day_selector.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RepetitionDialog extends StatefulWidget {
  final DateTime selectedStartDate;
  final DateTime selectedEndDate;
  final LegacyRecurrenceRule? initialRecurrenceRule;

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
  String? warningMessage;

  @override
  void initState() {
    super.initState();
    _selectedStartDate = widget.selectedStartDate;
    _selectedEndDate = widget.selectedEndDate;
    _fillVariablesFromInitialRecurrenceRule(widget.initialRecurrenceRule);

    // ✅ Trigger warning check after the first frame
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _updateWarningMessage());
  }

  void _fillVariablesFromInitialRecurrenceRule(LegacyRecurrenceRule? rule) {
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
    LegacyRecurrenceRule? recurrenceRule,
    bool? isRepetitiveUpdated,
  ) {
    setState(() {
      isRepeated = isRepetitiveUpdated ?? false;
    });
    Navigator.of(context).pop([recurrenceRule, isRepeated]);
  }

  void _updateWarningMessage() {
    final eventDay = CustomDayOfWeek.getPattern(
      DateFormat('EEEE', 'en_US').format(_selectedStartDate),
    );
    final requiredDay = CustomDayOfWeek.fromString(eventDay);

    setState(() {
      if (selectedFrequency == 'Weekly' &&
          !selectedDays.contains(requiredDay)) {
        warningMessage =
            AppLocalizations.of(context)!.eventDayNotIncludedWarning(
          DateFormat('EEEE').format(_selectedStartDate),
        );
      } else {
        warningMessage = null;
      }
    });
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
            RepeatFrequencySelector(
              selectedFrequency: selectedFrequency,
              onSelectFrequency: (frequency) {
                setState(() {
                  selectedFrequency = frequency;

                  if (frequency == 'Weekly') {
                    final eventDay = CustomDayOfWeek.getPattern(
                      DateFormat('EEEE', 'en_US').format(_selectedStartDate),
                    );
                    final requiredDay = CustomDayOfWeek.fromString(eventDay);
                    selectedDays.add(requiredDay);
                  }
                  _updateWarningMessage();
                });
              },
            ),
            const SizedBox(height: 12),
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
                    _updateWarningMessage();
                  });
                },
              ),
            const SizedBox(height: 12),
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
            if (validationError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  validationError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            if (warningMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  warningMessage!,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () {
                if (widget.initialRecurrenceRule != null) {
                  // Show confirmation dialog only if there's an existing recurrence rule
                  showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.confirm),
                      content: Text(AppLocalizations.of(context)!
                          .removeRecurrenceConfirm),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text(AppLocalizations.of(context)!.cancel),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(AppLocalizations.of(context)!.remove),
                        ),
                      ],
                    ),
                  ).then((confirmed) {
                    if (confirmed == true) {
                      Navigator.of(context).pop([null, false]);
                    }
                  });
                } else {
                  // Just close the dialog if there's no existing recurrence rule
                  _goBackToParentView(null, false);
                }
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
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

                _updateWarningMessage();

                setState(() {
                  validationError = result.error;

                  if (result.error == null && warningMessage == null) {
                    _goBackToParentView(result.rule, true);
                  }
                });
              },
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        ),
      ],
    );
  }
}
