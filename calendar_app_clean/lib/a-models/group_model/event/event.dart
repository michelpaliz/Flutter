import 'package:first_project/a-models/group_model/event_appointment/appointment/recurrence_rule.dart';
import 'package:first_project/a-models/notification_model/updateInfo.dart';

/// A simple mutable Event model without code generation.
class Event {
  String id;
  DateTime startDate;
  DateTime endDate;
  String title;
  String? groupId;
  String? calendarId;
  RecurrenceRule? recurrenceRule;
  String? localization;
  String? note;
  String? description;
  int eventColorIndex;
  bool allDay;
  int? reminderTime;
  bool isDone;
  DateTime? completedAt;
  List<String> recipients;
  String ownerId;
  List<UpdateInfo> updateHistory;

  Event({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title,
    this.groupId,
    this.calendarId,
    this.recurrenceRule,
    this.localization,
    this.note,
    this.description,
    this.eventColorIndex = 0,
    this.allDay = false,
    this.reminderTime,
    this.isDone = false,
    this.completedAt,
    List<String>? recipients,
    required this.ownerId,
    List<UpdateInfo>? updateHistory,
  })  : recipients = recipients ?? [],
        updateHistory = updateHistory ?? [];

  /// Adds an update record.
  void addUpdate(String userId) {
    updateHistory.add(UpdateInfo(userId: userId, updatedAt: DateTime.now()));
  }

  /// Creates a copy with optional new values.
  Event copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    String? title,
    String? groupId,
    String? calendarId,
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
      calendarId: calendarId ?? this.calendarId,
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

  /// Serializes to a Map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'title': title,
        'groupId': groupId,
        'calendarId': calendarId,
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

  /// Deserializes from a Map.
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      title: map['title'] as String,
      groupId: map['groupId'] as String?,
      calendarId: map['calendarId'] as String?,
      recurrenceRule: map['recurrenceRule'] != null
          ? RecurrenceRule.fromMap(
              map['recurrenceRule'] as Map<String, dynamic>)
          : null,
      localization: map['localization'] as String?,
      note: map['note'] as String?,
      description: map['description'] as String?,
      eventColorIndex: map['eventColorIndex'] as int,
      allDay: map['allDay'] as bool,
      reminderTime: map['reminderTime'] as int?,
      isDone: map['isDone'] as bool,
      completedAt: map['completedAt'] != null
          ? DateTime.tryParse(map['completedAt'] as String)
          : null,
      recipients: List<String>.from(map['recipients'] as List<dynamic>),
      ownerId: map['ownerId'] as String,
      updateHistory: (map['updateHistory'] as List<dynamic>)
          .map((e) => UpdateInfo.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// JSON serialization alias
  factory Event.fromJson(Map<String, dynamic> json) => Event.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  @override
  String toString() {
    return 'Event{'
        'id: $id, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'title: $title, '
        'groupId: $groupId, '
        'calendarId: $calendarId, '
        'recurrenceRule: $recurrenceRule, '
        'localization: $localization, '
        'note: $note, '
        'description: $description, '
        'eventColorIndex: $eventColorIndex, '
        'allDay: $allDay, '
        'reminderTime: $reminderTime, '
        'isDone: $isDone, '
        'completedAt: $completedAt, '
        'recipients: $recipients, '
        'ownerId: $ownerId, '
        'updateHistory: $updateHistory'
        '}';
  }

  @override
  bool operator ==(Object other) {
    return other is Event &&
        other.id == id &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.title == title &&
        other.calendarId == calendarId &&
        other.eventColorIndex == eventColorIndex; // ← include
  }

  @override
  int get hashCode =>
      id.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      title.hashCode ^
      calendarId.hashCode ^
      eventColorIndex.hashCode; // ← include
}
