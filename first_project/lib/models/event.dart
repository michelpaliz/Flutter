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
      // Retrieve the CustomAppointment properties from the JSON representation
    );
  }

  @override
  String toString() {
    return 'Event -- > {id: $id, startDate: $startDate, endDate: $endDate, '
        'title: $title, groupId: $groupId, recurrenceRule: $recurrenceRule, '
        'localization: $localization, note: $note, description: $description, '
        'eventColorIndex: $eventColorIndex, allDay: $allDay, done: $done}';
  }
}
