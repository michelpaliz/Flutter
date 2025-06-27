import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/custom_day_week.dart';
import 'package:calendar_app_frontend/c-frontend/c-event-section/utils/number_selector.dart';
import 'package:flutter/material.dart';
import 'package:calendar_app_frontend/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class RepeatEveryRow extends StatelessWidget {
  final String selectedFrequency;
  final int repeatInterval;
  final List<CustomDayOfWeek> selectedDays;
  final DateTime selectedStartDate;
  final Function(int) onIntervalChanged;

  const RepeatEveryRow({
    Key? key,
    required this.selectedFrequency,
    required this.repeatInterval,
    required this.selectedDays,
    required this.selectedStartDate,
    required this.onIntervalChanged,
  }) : super(key: key);

  int _getMaxRepeatValue(String frequency) {
    switch (frequency) {
      case 'Daily':
        return 500;
      case 'Weekly':
        return 18;
      case 'Monthly':
        return 18;
      case 'Yearly':
        return 10;
      default:
        return 0;
    }
  }

  String _getTranslatedSpecificFrequency(
    BuildContext context,
    String frequency,
  ) {
    switch (frequency) {
      case 'Daily':
        return AppLocalizations.of(context)!.dailys;
      case 'Weekly':
        return AppLocalizations.of(context)!.weeklys;
      case 'Monthly':
        return AppLocalizations.of(context)!.monthlies;
      case 'Yearly':
        return AppLocalizations.of(context)!.yearlys;
      default:
        return '';
    }
  }

  String _getTranslatedFrequencyDays(
    BuildContext context,
    List<String> dayNames,
  ) {
    List<String> translated = dayNames.map((day) {
      switch (day.toLowerCase()) {
        case 'monday':
          return AppLocalizations.of(context)!.monday;
        case 'tuesday':
          return AppLocalizations.of(context)!.tuesday;
        case 'wednesday':
          return AppLocalizations.of(context)!.wednesday;
        case 'thursday':
          return AppLocalizations.of(context)!.thursday;
        case 'friday':
          return AppLocalizations.of(context)!.friday;
        case 'saturday':
          return AppLocalizations.of(context)!.saturday;
        case 'sunday':
          return AppLocalizations.of(context)!.sunday;
        default:
          return day;
      }
    }).toList();

    return translated.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d of MMMM').format(selectedStartDate);
    final selectedDayNames = selectedDays.map((day) => day.name).toList();

    selectedDayNames.sort((a, b) {
      final orderA = customDaysOfWeek.firstWhere((d) => d.name == a).order;
      final orderB = customDaysOfWeek.firstWhere((d) => d.name == b).order;
      return orderA.compareTo(orderB);
    });

    String repeatMessage = '';
    switch (selectedFrequency) {
      case 'Daily':
        repeatMessage = AppLocalizations.of(
          context,
        )!
            .dailyRepetitionInf(repeatInterval);
        break;
      case 'Weekly':
        if (selectedDayNames.length > 1) {
          final lastDay = selectedDayNames.removeLast();
          final mainDays = _getTranslatedFrequencyDays(
            context,
            selectedDayNames,
          );
          final last = _getTranslatedFrequencyDays(context, [lastDay]);
          repeatMessage = AppLocalizations.of(
            context,
          )!
              .weeklyRepetitionInf(repeatInterval, "", last, mainDays);
        } else if (selectedDayNames.length == 1) {
          final onlyDay = _getTranslatedFrequencyDays(
            context,
            selectedDayNames,
          );
          repeatMessage = AppLocalizations.of(
            context,
          )!
              .weeklyRepetitionInf1(repeatInterval, onlyDay);
        } else {
          repeatMessage = AppLocalizations.of(context)!.noDaysSelected;
        }
        break;
      case 'Monthly':
        repeatMessage = AppLocalizations.of(
          context,
        )!
            .monthlyRepetitionInf(
                formattedDate, repeatInterval, repeatInterval);
        break;
      case 'Yearly':
        repeatMessage = AppLocalizations.of(
          context,
        )!
            .yearlyRepetitionInf(formattedDate, repeatInterval, repeatInterval);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15.0),
        Center(
          child: Text(
            AppLocalizations.of(context)!.repetitionDetails,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(repeatMessage, style: const TextStyle(fontSize: 14)),
        ),
        Row(
          children: [
            Text(
              AppLocalizations.of(context)!.every,
              style: const TextStyle(fontSize: 13),
            ),
            NumberSelector(
              key: Key(selectedFrequency),
              value: repeatInterval,
              minValue: 0,
              maxValue: _getMaxRepeatValue(selectedFrequency),
              onChanged: (int? value) {
                if (value != null) {
                  onIntervalChanged(value); // still calls your original logic
                }
              },
            ),
            Text(
              ' ${_getTranslatedSpecificFrequency(context, selectedFrequency)}',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}
