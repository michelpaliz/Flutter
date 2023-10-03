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
  });

  Map<String, dynamic> toMap() {
    return {
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
      'eventColorIndex': eventColorIndex, // Serialize color index
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    final recurrenceRuleJson = json['recurrenceRule'];
    RecurrenceRule? recurrenceRule;

    if (recurrenceRuleJson != null) {
      recurrenceRule = RecurrenceRule.fromMap(recurrenceRuleJson);
    }

    return Event(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      title: json['title'] ?? '',
      groupId: json['groupId'],
      done: json['done'] ?? false,
      recurrenceRule: recurrenceRule,
      localization: json['localization'] ?? '',
      allDay: json['allDay'] ?? false,
      note: json['note'] ?? '',
      description: json['description'] ?? '',
      eventColorIndex: json['eventColorIndex'], // Deserialize color index
    );
  }

  List<Event> generateRecurringOccurrences(
      DateTime startDate, DateTime endDate) {
    final List<Event> occurrences = [];

    if (recurrenceRule != null) {
      // Calculate recurring dates using recurrence rule logic here
      // Append the recurring events to the 'occurrences' list
    } else {
      // If there is no recurrence rule, simply add the original event
      occurrences.add(this);
    }

    return occurrences;
  }
}
