// Import your custom enum
import 'dart:core';
import 'package:first_project/models/custom_day_week.dart';

enum RecurrenceType { Daily, Weekly, Monthly, Yearly }

class RecurrenceRule {
  final String name;
  final List<CustomDayOfWeek>? daysOfWeek; // List of days for weekly recurrence
  final int? dayOfMonth;
  final int? month;
  final int? repeatInterval; // Number of intervals for recurrence
  final RecurrenceType recurrenceType;
  final DateTime? untilDate; // End date for recurrence

  const RecurrenceRule.daily({this.repeatInterval, this.untilDate})
      : name = 'Daily',
        daysOfWeek = null,
        dayOfMonth = null,
        month = null,
        recurrenceType = RecurrenceType.Daily;

  const RecurrenceRule.weekly(this.daysOfWeek,
      {this.repeatInterval, this.untilDate})
      : name = 'Weekly',
        dayOfMonth = null,
        month = null,
        recurrenceType = RecurrenceType.Weekly;

  const RecurrenceRule.monthly(
      {this.dayOfMonth, this.repeatInterval, this.untilDate})
      : name = 'Monthly',
        daysOfWeek = null,
        month = null,
        recurrenceType = RecurrenceType.Monthly;

  const RecurrenceRule.yearly(
      {this.month, this.dayOfMonth, this.repeatInterval, this.untilDate})
      : name = 'Yearly',
        daysOfWeek = null,
        recurrenceType = RecurrenceType.Yearly;

  static RecurrenceRule? fromString(String ruleString,
      {int? month, int? dayOfMonth}) {
    switch (ruleString) {
      case 'daily':
        return RecurrenceRule.daily();
      case 'weekly':
        return RecurrenceRule.weekly(null,
            repeatInterval: null, untilDate: null);
      case 'monthly':
        return RecurrenceRule.monthly(
            dayOfMonth: null, repeatInterval: null, untilDate: null);
      case 'yearly':
        return RecurrenceRule.yearly(
            month: month,
            dayOfMonth: dayOfMonth,
            repeatInterval: null,
            untilDate: null);
      default:
        return null; // Handle unrecognized ruleString
    }
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer('RecurrenceRule {');
    buffer.write('name: $name, ');
    if (daysOfWeek != null) {
      buffer.write('daysOfWeek: $daysOfWeek, ');
    }
    if (dayOfMonth != null) {
      buffer.write('dayOfMonth: $dayOfMonth, ');
    }
    if (month != null) {
      buffer.write('month: $month, ');
    }
    if (repeatInterval != null) {
      buffer.write('repeatInterval: $repeatInterval, ');
    }
    buffer.write('recurrenceType: $recurrenceType, ');
    if (untilDate != null) {
      buffer.write('untilDate: $untilDate');
    }
    buffer.write('}');
    return buffer.toString();
  }
}
