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

  RecurrenceRule({
    required this.name,
    this.daysOfWeek,
    this.dayOfMonth,
    this.month,
    this.repeatInterval,
    required this.recurrenceType,
    this.untilDate,
  });

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

  // Getter methods for accessing attributes
  List<CustomDayOfWeek>? getDaysOfWeek() {
    return daysOfWeek;
  }

  int? getDayOfMonth() {
    return dayOfMonth;
  }

  int? getMonth() {
    return month;
  }

  int? getRepeatInterval() {
    return repeatInterval;
  }

  RecurrenceType getRecurrenceType() {
    return recurrenceType;
  }

  DateTime? getUntilDate() {
    return untilDate;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'name': name,
      'recurrenceType': recurrenceType.toString(),
    };
    if (daysOfWeek != null) {
      map['daysOfWeek'] = daysOfWeek!.map((day) => day.name).toList();
    }
    if (dayOfMonth != null) {
      map['dayOfMonth'] = dayOfMonth;
    }
    if (month != null) {
      map['month'] = month;
    }
    if (repeatInterval != null) {
      map['repeatInterval'] = repeatInterval;
    }
    if (untilDate != null) {
      map['untilDate'] = untilDate!.toIso8601String();
    }
    return map;
  }

factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
  final String name = map['name'] ?? '';
  final String recurrenceTypeString = map['recurrenceType'] ?? 'Daily';
  final RecurrenceType recurrenceType = _mapStringToRecurrenceType(recurrenceTypeString);

  List<CustomDayOfWeek>? daysOfWeek;
  if (map['daysOfWeek'] != null) {
    daysOfWeek = (map['daysOfWeek'] as List<dynamic>)
        .map((day) => CustomDayOfWeek.fromString(day.toString())) // Cast day to String
        .toList();
  }

  final int? dayOfMonth = map['dayOfMonth'];
  final int? month = map['month'];
  final int? repeatInterval = map['repeatInterval'];

  DateTime? untilDate;
  if (map['untilDate'] != null) {
    untilDate = DateTime.tryParse(map['untilDate'].toString()); // Cast untilDate to String
  }

  return RecurrenceRule(
    name: name,
    daysOfWeek: daysOfWeek,
    dayOfMonth: dayOfMonth,
    month: month,
    repeatInterval: repeatInterval,
    recurrenceType: recurrenceType,
    untilDate: untilDate,
  );
}


static RecurrenceType _mapStringToRecurrenceType(String recurrenceTypeString) {
  switch (recurrenceTypeString.toLowerCase()) {
    case 'daily':
      return RecurrenceType.Daily;
    case 'weekly':
      return RecurrenceType.Weekly;
    case 'monthly':
      return RecurrenceType.Monthly;
    case 'yearly':
      return RecurrenceType.Yearly;
    default:
      return RecurrenceType.Daily; // Default to Daily if unrecognized
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
