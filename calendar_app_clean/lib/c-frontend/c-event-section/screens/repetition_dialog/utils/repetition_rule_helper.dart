import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/a-models/group_model/event_appointment/appointment/custom_day_week.dart';

class RepetitionResult {
  final RecurrenceRule? rule;
  final String? error;

  RepetitionResult({this.rule, this.error});
}

RepetitionResult validateAndCreateRecurrenceRule({
  required BuildContext context,
  required String frequency,
  required int? repeatInterval,
  required bool isForever,
  required DateTime? untilDate,
  required DateTime selectedStartDate,
  required DateTime selectedEndDate,
  required Set<CustomDayOfWeek> selectedDays,
  int? dayOfMonth,
  int? selectedMonth,
}) {
  final localizations = AppLocalizations.of(context)!;

  if (repeatInterval == 0) {
    return RepetitionResult(error: localizations.specifyRepeatInterval);
  }

  if (!isForever && untilDate == null) {
    return RepetitionResult(error: localizations.untilDate);
  }

  switch (frequency) {
    case 'Weekly':
      if (selectedDays.isEmpty) {
        return RepetitionResult(error: localizations.selectOneDayAtLeast);
      }

      final eventDayAbbreviation = CustomDayOfWeek.getPattern(
        DateFormat('EEEE', 'en_US').format(selectedStartDate),
      );

      final requiredDay = CustomDayOfWeek.fromString(eventDayAbbreviation);
      if (!selectedDays.contains(requiredDay)) {
        return RepetitionResult(
          error: localizations.errorSelectedDays(
            localizations
                .untilDateSelected(DateFormat('EEEE').format(selectedStartDate)),
          ),
        );
      }
      break;
    default:
      break;
  }

  // Create recurrence rule
  RecurrenceRule rule;
  switch (frequency) {
    case 'Daily':
      rule = RecurrenceRule.daily(
        repeatInterval: repeatInterval,
        untilDate: isForever ? null : untilDate,
      );
      break;
    case 'Weekly':
      rule = RecurrenceRule.weekly(
        selectedDays.toList(),
        repeatInterval: repeatInterval,
        untilDate: isForever ? null : untilDate,
      );
      break;
    case 'Monthly':
      rule = RecurrenceRule.monthly(
        dayOfMonth: dayOfMonth,
        repeatInterval: repeatInterval,
        untilDate: isForever ? null : untilDate,
      );
      break;
    case 'Yearly':
      rule = RecurrenceRule.yearly(
        month: selectedMonth,
        dayOfMonth: dayOfMonth,
        repeatInterval: repeatInterval,
        untilDate: isForever ? null : untilDate,
      );
      break;
    default:
      rule = RecurrenceRule.daily();
  }

  return RepetitionResult(rule: rule);
}
