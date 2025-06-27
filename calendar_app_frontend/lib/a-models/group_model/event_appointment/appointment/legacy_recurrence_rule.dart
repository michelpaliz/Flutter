import 'dart:core';

import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/custom_day_of_week_extensions.dart';
import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/custom_day_week.dart';
import 'package:uuid/uuid.dart'; // Add the UUID package

enum RecurrenceType { Daily, Weekly, Monthly, Yearly }

class LegacyRecurrenceRule {
  final String id; // Unique identifier
  final String name;
  final List<CustomDayOfWeek>? daysOfWeek;
  final int? dayOfMonth;
  final int? month;
  final int? repeatInterval; // Number of intervals for recurrence
  final RecurrenceType recurrenceType;
  final DateTime? untilDate; // End date for recurrence

  // Constructor with optional id
  LegacyRecurrenceRule({
    String? id,
    required this.name,
    this.daysOfWeek,
    this.dayOfMonth,
    this.month,
    this.repeatInterval,
    required this.recurrenceType,
    this.untilDate,
  }) : id = id ?? Uuid().v4(); // Generate id if not provided

  // Named constructor for Daily recurrence
  LegacyRecurrenceRule.daily({this.repeatInterval, this.untilDate})
      : id = Uuid().v4(), // Generate unique ID without const
        name = 'Daily',
        daysOfWeek = null,
        dayOfMonth = null,
        month = null,
        recurrenceType = RecurrenceType.Daily;

  // Named constructor for Weekly recurrence
  LegacyRecurrenceRule.weekly(this.daysOfWeek,
      {this.repeatInterval, this.untilDate})
      : id = Uuid().v4(), // Generate unique ID without const
        name = 'Weekly',
        dayOfMonth = null,
        month = null,
        recurrenceType = RecurrenceType.Weekly;

  // Named constructor for Monthly recurrence
  LegacyRecurrenceRule.monthly(
      {this.dayOfMonth, this.repeatInterval, this.untilDate})
      : id = Uuid().v4(), // Generate unique ID without const
        name = 'Monthly',
        daysOfWeek = null,
        month = null,
        recurrenceType = RecurrenceType.Monthly;

  // Named constructor for Yearly recurrence
  LegacyRecurrenceRule.yearly({
    this.month,
    this.dayOfMonth,
    this.repeatInterval,
    this.untilDate,
  })  : id = Uuid().v4(), // Generate unique ID without const
        name = 'Yearly',
        daysOfWeek = null,
        recurrenceType = RecurrenceType.Yearly;

  // Convert the object to a map for JSON serialization
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'id': id, // Include id in map
      'name': name,
      // 'recurrenceType': recurrenceType.toString(),
      'recurrenceType': recurrenceType.name, // ✅ FIXED HERE
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

  // Factory constructor to create an object from a map (JSON deserialization)
  factory LegacyRecurrenceRule.fromMap(Map<String, dynamic> map) {
    final String id = map['id'] ?? Uuid().v4(); // Generate new ID if missing
    final String name = map['name'] ?? '';
    final RecurrenceType recurrenceType = _mapStringToRecurrenceType(name);

    List<CustomDayOfWeek>? daysOfWeek;
    if (map['daysOfWeek'] != null) {
      daysOfWeek = (map['daysOfWeek'] as List<dynamic>)
          .map((day) => CustomDayOfWeek.fromString(day.toString()))
          .toList();
    }

    final int? dayOfMonth = map['dayOfMonth'];
    final int? month = map['month'];
    final int? repeatInterval = map['repeatInterval'];

    DateTime? untilDate;
    if (map['untilDate'] != null) {
      untilDate = DateTime.tryParse(map['untilDate']);
    }

    return LegacyRecurrenceRule(
      id: id,
      name: name,
      daysOfWeek: daysOfWeek,
      dayOfMonth: dayOfMonth,
      month: month,
      repeatInterval: repeatInterval,
      recurrenceType: recurrenceType,
      untilDate: untilDate,
    );
  }

  static RecurrenceType _mapStringToRecurrenceType(
    String recurrenceTypeString,
  ) {
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
    buffer.write('id: $id, '); // Include id in toString
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'recurrenceType':
          recurrenceType.name, // Use `.name` instead of .toString()
      'repeatInterval': repeatInterval,
      'untilDate': untilDate?.toIso8601String(),
      'daysOfWeek': daysOfWeek?.map((day) => day.name).toList(),
      'dayOfMonth': dayOfMonth,
      'month': month,
    };
  }

  factory LegacyRecurrenceRule.fromJson(Map<String, dynamic> json) {
    return LegacyRecurrenceRule(
      id: json['id'] ?? const Uuid().v4(),
      name: json['name'] ?? '',
      recurrenceType: _mapStringToRecurrenceType(
        json['recurrenceType'] ?? 'Daily',
      ),
      repeatInterval: json['repeatInterval'],
      untilDate: json['untilDate'] != null
          ? DateTime.tryParse(json['untilDate'])
          : null,
      daysOfWeek: json['daysOfWeek'] != null
          ? (json['daysOfWeek'] as List<dynamic>)
              .map((day) => CustomDayOfWeek.fromString(day.toString()))
              .toList()
          : null,
      dayOfMonth: json['dayOfMonth'],
      month: json['month'],
    );
  }

  String toRRuleString(DateTime startDate) {
  final buffer = StringBuffer();

  // Add DTSTART first – in UTC format
  final dtStart = startDate.toUtc()
      .toIso8601String()
      .replaceAll('-', '')
      .replaceAll(':', '')
      .split('.')
      .first + 'Z';
  buffer.writeln('DTSTART:$dtStart');

  // Now the actual RRULE line
  buffer.write('RRULE:FREQ=${recurrenceType.name.toUpperCase()}');

  final interval = repeatInterval ?? 1;
  buffer.write(';INTERVAL=$interval');

  if (untilDate != null) {
    final until = untilDate!
        .toUtc()
        .toIso8601String()
        .replaceAll('-', '')
        .replaceAll(':', '')
        .split('.')
        .first + 'Z';
    buffer.write(';UNTIL=$until');
  }

  if (recurrenceType == RecurrenceType.Weekly &&
      daysOfWeek != null &&
      daysOfWeek!.isNotEmpty) {
    final byDay = daysOfWeek!.map((d) => d.toRRuleDay()).join(',');
    buffer.write(';BYDAY=$byDay');
  }

  if ((recurrenceType == RecurrenceType.Monthly ||
          recurrenceType == RecurrenceType.Yearly) &&
      dayOfMonth != null) {
    buffer.write(';BYMONTHDAY=$dayOfMonth');
  }

  if (recurrenceType == RecurrenceType.Yearly && month != null) {
    buffer.write(';BYMONTH=$month');
  }

  return buffer.toString();
}

}
