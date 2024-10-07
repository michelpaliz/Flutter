import 'dart:core';
import 'package:first_project/a-models/custom_day_week.dart';
import 'package:uuid/uuid.dart'; // Add the UUID package

enum RecurrenceType { Daily, Weekly, Monthly, Yearly }

class RecurrenceRule {
  final String id; // Unique identifier
  final String name;
  final List<CustomDayOfWeek>? daysOfWeek;
  final int? dayOfMonth;
  final int? month;
  final int? repeatInterval; // Number of intervals for recurrence
  final RecurrenceType recurrenceType;
  final DateTime? untilDate; // End date for recurrence

  // Constructor with optional id
  RecurrenceRule({
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
  RecurrenceRule.daily({this.repeatInterval, this.untilDate})
      : id = Uuid().v4(), // Generate unique ID without const
        name = 'Daily',
        daysOfWeek = null,
        dayOfMonth = null,
        month = null,
        recurrenceType = RecurrenceType.Daily;

  // Named constructor for Weekly recurrence
  RecurrenceRule.weekly(this.daysOfWeek, {this.repeatInterval, this.untilDate})
      : id = Uuid().v4(), // Generate unique ID without const
        name = 'Weekly',
        dayOfMonth = null,
        month = null,
        recurrenceType = RecurrenceType.Weekly;

  // Named constructor for Monthly recurrence
  RecurrenceRule.monthly({this.dayOfMonth, this.repeatInterval, this.untilDate})
      : id = Uuid().v4(), // Generate unique ID without const
        name = 'Monthly',
        daysOfWeek = null,
        month = null,
        recurrenceType = RecurrenceType.Monthly;

  // Named constructor for Yearly recurrence
  RecurrenceRule.yearly({this.month, this.dayOfMonth, this.repeatInterval, this.untilDate})
      : id = Uuid().v4(), // Generate unique ID without const
        name = 'Yearly',
        daysOfWeek = null,
        recurrenceType = RecurrenceType.Yearly;

  // Convert the object to a map for JSON serialization
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'id': id, // Include id in map
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

  // Factory constructor to create an object from a map (JSON deserialization)
  factory RecurrenceRule.fromMap(Map<String, dynamic> map) {
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

    return RecurrenceRule(
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
}
