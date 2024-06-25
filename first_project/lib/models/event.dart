import 'package:first_project/models/recurrence_rule.dart';

class Event {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String? groupId;
  final RecurrenceRule? recurrenceRule;
  final String? localization;
  final String? note;
  final String? description;
  final int eventColorIndex; // Store the index of the color
  late final bool allDay;
  bool done;
  final String? recipient; // New attribute for recipient
  final String?
      updatedByText; // New attribute for the person/user who updated the event

  Event({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title,
    this.groupId,
    this.done = false,
    this.recurrenceRule,
    this.localization,
    this.allDay = false,
    this.note,
    this.description,
    required this.eventColorIndex, // Store the color index
    this.recipient, // Initialize recipient
    this.updatedByText, // Initialize updatedByText
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> json = {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'title': title,
      'groupId': groupId,
      'done': done,
      if (recurrenceRule != null) 'recurrenceRule': recurrenceRule!.toMap(),
      if (localization != null) 'localization': localization,
      'allDay': allDay,
      if (note != null) 'note': note,
      if (description != null) 'description': description,
      'eventColorIndex': eventColorIndex,
      if (recipient != null) 'recipient': recipient, // Add recipient to map
      if (updatedByText != null)
        'updatedByText': updatedByText, // Add updatedByText to map
    };
    return json;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    final recurrenceRuleJson = json['recurrenceRule'];
    RecurrenceRule? recurrenceRule;

    if (recurrenceRuleJson != null) {
      recurrenceRule = RecurrenceRule.fromMap(recurrenceRuleJson);
    }

    return Event(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']).toUtc(),
      endDate: DateTime.parse(json['endDate']).toUtc(),
      title: json['title'] ?? '',
      groupId: json['groupId'],
      done: json['done'] ?? false,
      recurrenceRule: recurrenceRule,
      localization: json['localization'] ?? '',
      allDay: json['allDay'] ?? false,
      note: json['note'] ?? '',
      description: json['description'] ?? '',
      eventColorIndex: json['eventColorIndex'],
      recipient: json['recipient'], // Parse recipient from JSON
      updatedByText: json['updatedByText'], // Parse updatedByText from JSON
    );
  }

  @override
  String toString() {
    return 'Event -- > {id: $id, startDate: $startDate, endDate: $endDate, '
        'title: $title, groupId: $groupId, recurrenceRule: $recurrenceRule, '
        'localization: $localization, note: $note, description: $description, '
        'eventColorIndex: $eventColorIndex, allDay: $allDay, done: $done, '
        'recipient: $recipient, updatedByText: $updatedByText}'; // Include new attributes in toString
  }
}
