
import 'package:first_project/a-models/recurrence_rule.dart';
import 'package:first_project/a-models/model/group_data/updateInfo.dart';

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
  final List<String> recipients; // Changed to List<String> with default empty list
  final String ownerID; // Changed to ownerID for consistency
  List<UpdateInfo> updateHistory; // New list to store update information

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
    List<String>? recipients, // Initialize recipient as a list with default
    required this.ownerID, // Initialize ownerID
    List<UpdateInfo>? updateHistory, // Initialize updateHistory
  })  : recipients = recipients ?? [],
        updateHistory = updateHistory ?? [];

  // Method to add an update record
  void addUpdate(String userId) {
    updateHistory.add(UpdateInfo(userId: userId, updatedAt: DateTime.now()));
  }

  // Method to create a new Event instance with modified fields (immutability)
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
    bool? done,
    List<String>? recipients,
    String? ownerID,
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
      done: done ?? this.done,
      recipients: recipients ?? List.from(this.recipients),
      ownerID: ownerID ?? this.ownerID,
      updateHistory: updateHistory != null
          ? List.from(updateHistory.map((info) => info.copyWith()))
          : List.from(this.updateHistory),
    );
  }

  // Convert the object to a map for JSON serialization
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
      'recipients': recipients, // Consistent naming
      'ownerID': ownerID, // Consistent naming
      'updateHistory': updateHistory
          .map((updateInfo) => updateInfo.toMap())
          .toList(), // Add update history to map
    };
    return json;
  }

  // Factory constructor to create an object from a map (JSON deserialization)
  factory Event.fromJson(Map<String, dynamic> json) {
    try {
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
        recipients: (json['recipients'] as List<dynamic>?)
            ?.map((item) => item as String)
            .toList() ?? [], // Ensure no null issues for recipients
        ownerID: json['ownerID'], // Consistent naming for ownerID
        updateHistory: (json['updateHistory'] as List<dynamic>?)
            ?.map((item) => UpdateInfo.fromMap(item as Map<String, dynamic>))
            .toList() ?? [], // Ensure no null issues for updateHistory
      );
    } catch (e) {
      throw Exception('Error parsing Event: $e');
    }
  }

  @override
  String toString() {
    return 'Event -- > {id: $id, startDate: $startDate, endDate: $endDate, '
        'title: $title, groupId: $groupId, recurrenceRule: $recurrenceRule, '
        'localization: $localization, note: $note, description: $description, '
        'eventColorIndex: $eventColorIndex, allDay: $allDay, done: $done, '
        'recipients: ${recipients.join(', ')}, ownerID: $ownerID, '
        'updateHistory: $updateHistory}'; // Format lists for readability
  }
}
