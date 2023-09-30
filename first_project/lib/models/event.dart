import 'package:first_project/models/recurrence_rule.dart';
import 'package:flutter/material.dart'; // Import the Flutter Material library for Color

class Event {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String title; // Required title field
  final String? groupId; // Optional property for the group ID
  final RecurrenceRule? recurrenceRule; // Optional recurrenceRule field
  final String? localization; // Optional localization field
  final String? note; // Optional note field
  final String? description; // Optional description field
  final Color eventColor; // Color for the event (default to transparent)
  late final bool allDay; // Optional allDay field with default value false
  bool done;

  Event({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title, // Required title field
    this.groupId,
    this.done = false,
    this.recurrenceRule,
    this.localization,
    this.allDay = false, // Default value for allDay
    this.note, // Optional note field
    this.description, // Optional description field
    Color? eventColor, // Color for the event (default to transparent)
  }) : eventColor = eventColor ?? Colors.transparent; // Set default to transparent

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'title': title, // Serialize title
      'groupId': groupId,
      'done': done,
      if (recurrenceRule != null) 'recurrenceRule': recurrenceRule!.toMap(),
      if (localization != null) 'localization': localization,
      'allDay': allDay, // Serialize allDay
      if (note != null) 'note': note, // Serialize note if not null
      if (description != null)
        'description': description, // Serialize description if not null
      'eventColor': eventColor.value, // Serialize eventColor as an integer value
    };
  }

factory Event.fromJson(Map<String, dynamic> json) {
  final recurrenceRuleJson = json['recurrenceRule'];
  RecurrenceRule? recurrenceRule;

  if (recurrenceRuleJson != null) {
    recurrenceRule = RecurrenceRule.fromMap(recurrenceRuleJson);
  }

  final int? eventColorValue = json['eventColor'];
  final Color eventColor = eventColorValue != null
      ? Color(eventColorValue) // Convert to Color if not null
      : Colors.transparent; // Default to transparent if null

  return Event(
    id: json['id'],
    startDate: DateTime.parse(json['startDate']),
    endDate: DateTime.parse(json['endDate']),
    title:
        json['title'] ?? '', // Deserialize title with a default empty string
    groupId: json['groupId'],
    done: json['done'] ?? false,
    recurrenceRule: recurrenceRule,
    localization: json['localization'] ??
        '', // Provide a default empty string for localization
    allDay: json['allDay'] ??
        false, // Deserialize allDay with default value false
    note: json['note'] ?? '', // Provide a default empty string for note
    description: json['description'] ??
        '', // Provide a default empty string for description
    eventColor: eventColor, // Use the Color value or default to transparent
  );
}
}
