import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/a-models/notification_model/updateInfo.dart';

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
  final int eventColorIndex;
  final bool allDay;
  final int? reminderTime;
  bool isDone;
  DateTime? completedAt;
  final List<String> recipients;
  final String ownerId;
  List<UpdateInfo> updateHistory;

  Event({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title,
    this.groupId,
    this.recurrenceRule,
    this.localization,
    this.note,
    this.description,
    required this.eventColorIndex,
    this.allDay = false,
    this.reminderTime,
    this.isDone = false,
    this.completedAt,
    List<String>? recipients,
    required this.ownerId,
    List<UpdateInfo>? updateHistory,
  })  : recipients = recipients ?? [],
        updateHistory = updateHistory ?? [];

  void addUpdate(String userId) {
    updateHistory.add(UpdateInfo(userId: userId, updatedAt: DateTime.now()));
  }

  Event copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    String? title,
    String? groupId,
    RecurrenceRule? recurrenceRule,
    String? localization,
    String? note,
    String? description,
    int? eventColorIndex,
    bool? allDay,
    int? reminderTime,
    bool? isDone,
    DateTime? completedAt,
    List<String>? recipients,
    String? ownerId,
    List<UpdateInfo>? updateHistory,
  }) {
    return Event(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      title: title ?? this.title,
      groupId: groupId ?? this.groupId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      localization: localization ?? this.localization,
      note: note ?? this.note,
      description: description ?? this.description,
      eventColorIndex: eventColorIndex ?? this.eventColorIndex,
      allDay: allDay ?? this.allDay,
      reminderTime: reminderTime ?? this.reminderTime,
      isDone: isDone ?? this.isDone,
      completedAt: completedAt ?? this.completedAt,
      recipients: recipients ?? List.from(this.recipients),
      ownerId: ownerId ?? this.ownerId,
      updateHistory: updateHistory != null
          ? List.from(updateHistory.map((u) => u.copyWith()))
          : List.from(this.updateHistory),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'title': title,
      'groupId': groupId,
      'recurrenceRule': recurrenceRule?.toMap(),
      'localization': localization,
      'note': note,
      'description': description,
      'eventColorIndex': eventColorIndex,
      'allDay': allDay,
      'reminderTime': reminderTime,
      'isDone': isDone,
      'completedAt': completedAt?.toIso8601String(),
      'recipients': recipients,
      'ownerId': ownerId,
      'updateHistory': updateHistory.map((u) => u.toMap()).toList(),
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']).toUtc(),
      endDate: DateTime.parse(json['endDate']).toUtc(),
      title: json['title'] ?? '',
      groupId: json['groupId'],
      recurrenceRule: json['recurrenceRule'] != null
          ? RecurrenceRule.fromMap(json['recurrenceRule'])
          : null,
      localization: json['localization'],
      note: json['note'],
      description: json['description'],
      eventColorIndex: json['eventColorIndex'],
      allDay: json['allDay'] ?? false,
      reminderTime: json['reminderTime'],
      isDone: json['isDone'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'])
          : null,
      recipients: (json['recipients'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList() ??
          [],
      ownerId: json['ownerId'],
      updateHistory: (json['updateHistory'] as List<dynamic>?)
              ?.map((item) => UpdateInfo.fromMap(item))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, start: $startDate, end: $endDate, title: $title, '
        'groupId: $groupId, recurrenceRule: $recurrenceRule, location: $localization, '
        'note: $note, desc: $description, color: $eventColorIndex, allDay: $allDay, '
        'isDone: $isDone, completedAt: $completedAt, recipients: $recipients, '
        'ownerId: $ownerId, updates: $updateHistory}';
  }
}
