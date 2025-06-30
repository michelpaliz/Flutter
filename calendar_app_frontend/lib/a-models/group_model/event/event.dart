import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/custom_day_week.dart';
import 'package:calendar_app_frontend/a-models/group_model/event_appointment/appointment/legacy_recurrence_rule.dart';
import 'package:calendar_app_frontend/a-models/notification_model/updateInfo.dart';

/// A simple mutable Event model without code generation.
class Event {
  String id;
  DateTime startDate;
  DateTime endDate;
  String title;
  String? groupId;
  String? calendarId;
  LegacyRecurrenceRule? recurrenceRule;
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
  final String? rawRuleId;

  Event({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title,
    this.groupId,
    this.calendarId,
    this.recurrenceRule,
    this.rawRuleId,
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
    LegacyRecurrenceRule? recurrenceRule,
    String? rawRuleId,
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
      rawRuleId: rawRuleId ?? this.rawRuleId,
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
        'startDate': startDate.toUtc().toIso8601String(), // 👈 convert to UTC
        'endDate': endDate.toUtc().toIso8601String(), // 👈 convert to UTC
        'title': title,
        'groupId': groupId,
        'calendarId': calendarId,
        'recurrenceRule': recurrenceRule?.toMap(),
        'rawRuleId': rawRuleId,
        'localization': localization,
        'note': note,
        'description': description,
        'eventColorIndex': eventColorIndex,
        'allDay': allDay,
        'reminderTime': reminderTime,
        'isDone': isDone,
        'completedAt':
            completedAt?.toUtc().toIso8601String(), // ✅ optional, safe
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
      recurrenceRule: map['recurrenceRule'] == null
          ? null
          : map['recurrenceRule'] is String
              ? LegacyRecurrenceRule(
                  id: map['recurrenceRule'],
                  name: 'Imported',
                  recurrenceType: RecurrenceType.Daily)
              : LegacyRecurrenceRule.fromMap(
                  map['recurrenceRule'] as Map<String, dynamic>),
      rawRuleId: map['rawRuleId'] as String?,
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

  String? get rule => recurrenceRule?.toRRuleString(startDate);

  /// JSON serialization alias
  factory Event.fromJson(Map<String, dynamic> json) => Event.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toBackendJson() {
    final recurrenceRuleJson = recurrenceRule == null
        ? null
        : (RegExp(r'^[a-f0-9]{24}$').hasMatch(recurrenceRule!.id)
            ? recurrenceRule!.id
            : recurrenceRule!.toMap()); // ✅ FIX: send full object if no ID

    return {
      'id': id,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'title': title,
      'groupId': groupId,
      'calendarId': calendarId,
      'recurrenceRule': recurrenceRuleJson, // 👈 fixed
      'localization': localization,
      'note': note,
      'description': description,
      'eventColorIndex': eventColorIndex,
      'allDay': allDay,
      'reminderTime': reminderTime,
      'isDone': isDone,
      'completedAt': completedAt?.toUtc().toIso8601String(),
      'recipients': recipients,
      'ownerId': ownerId,
      'updateHistory': updateHistory.map((u) => u.toMap()).toList(),
    };
  }

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

  /// Returns a human-readable recurrence summary string.
  /// You might call .toString() to show "Thursday, June 27, 2025" to the user.
  String get recurrenceDescription {
    final rule = recurrenceRule;
    if (rule == null) return '';

    final buffer = StringBuffer('Repeats ');

    switch (rule.recurrenceType) {
      case RecurrenceType.Daily:
        buffer.write('every ${rule.repeatInterval ?? 1} day(s)');
        break;
      case RecurrenceType.Weekly:
        buffer.write('weekly');
        if (rule.daysOfWeek != null && rule.daysOfWeek!.isNotEmpty) {
          final days = rule.daysOfWeek!.map((d) => d.shortName).join(', ');
          buffer.write(' on $days');
        }
        break;
      case RecurrenceType.Monthly:
        if (rule.dayOfMonth != null) {
          buffer.write('monthly on day ${rule.dayOfMonth}');
        } else {
          buffer.write('monthly');
        }
        break;
      case RecurrenceType.Yearly:
        if (rule.month != null && rule.dayOfMonth != null) {
          buffer.write('yearly on ${rule.month}/${rule.dayOfMonth}');
        } else {
          buffer.write('yearly');
        }
        break;
    }

    if (rule.untilDate != null) {
      final dateStr =
          rule.untilDate!.toLocal().toIso8601String().split('T').first;
      buffer.write(' until $dateStr');
    }

    return buffer.toString();
  }
}
