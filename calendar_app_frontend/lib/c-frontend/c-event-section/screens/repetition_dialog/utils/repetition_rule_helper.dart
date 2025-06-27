import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/custom_day_week.dart';
import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RepetitionResult {
  final LegacyRecurrenceRule? rule;
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
            localizations.untilDateSelected(
              DateFormat('EEEE').format(selectedStartDate),
            ),
          ),
        );
      }
      break;
    default:
      break;
  }

  // Create recurrence rule
  LegacyRecurrenceRule rule;
  switch (frequency) {
    case 'Daily':
      rule = LegacyRecurrenceRule.daily(
        repeatInterval: repeatInterval,
        untilDate: isForever ? null : untilDate,
      );
      break;
    case 'Weekly':
      rule = LegacyRecurrenceRule.weekly(
        selectedDays.toList(),
        repeatInterval: repeatInterval,
        untilDate: isForever ? null : untilDate,
      );
      break;
    case 'Monthly':
      rule = LegacyRecurrenceRule.monthly(
        dayOfMonth: dayOfMonth,
        repeatInterval: repeatInterval,
        untilDate: isForever ? null : untilDate,
      );
      break;
    case 'Yearly':
      rule = LegacyRecurrenceRule.yearly(
        month: selectedMonth,
        dayOfMonth: dayOfMonth,
        repeatInterval: repeatInterval,
        untilDate: isForever ? null : untilDate,
      );
      break;
    default:
      rule = LegacyRecurrenceRule.daily();
  }

  return RepetitionResult(rule: rule);
}
