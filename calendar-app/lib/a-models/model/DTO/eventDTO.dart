import 'package:first_project/a-models/model/group_data/event-appointment/event/event.dart';

class EventDTO {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String? groupId; // Keep groupId as String reference
  final String? recurrenceRuleId; // Use an ID reference for RecurrenceRule (if managed separately)
  final String? localization;
  final String? note;
  final String? description;
  final int eventColorIndex; // Store the index of the color
  final bool allDay;
  final bool done;
  final List<String> recipients; // List of user IDs
  final String ownerID; // Owner ID as user reference
  final List<Map<String, dynamic>> updateHistory; // Store updates as a list of {userId, updatedAt}

  EventDTO({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title,
    this.groupId,
    this.recurrenceRuleId,
    this.localization,
    this.note,
    this.description,
    required this.eventColorIndex,
    this.allDay = false,
    this.done = false,
    required this.recipients, // List of recipient IDs
    required this.ownerID, // Owner ID reference
    required this.updateHistory, // List of update history {userId, updatedAt}
  });

  // Convert Event model to EventDTO
  factory EventDTO.fromEvent(Event event) {
    return EventDTO(
      id: event.id,
      startDate: event.startDate,
      endDate: event.endDate,
      title: event.title,
      groupId: event.groupId,
      recurrenceRuleId: event.recurrenceRule?.id, // Reference recurrence rule by ID
      localization: event.localization,
      note: event.note,
      description: event.description,
      eventColorIndex: event.eventColorIndex,
      allDay: event.allDay,
      done: event.done,
      recipients: event.recipients,
      ownerID: event.ownerID,
      updateHistory: event.updateHistory
          .map((updateInfo) => {'userId': updateInfo.userId, 'updatedAt': updateInfo.updatedAt.toIso8601String()})
          .toList(), // Convert update history to list of maps
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'title': title,
      'groupId': groupId,
      'recurrenceRuleId': recurrenceRuleId, // Save recurrenceRule as an ID reference
      'localization': localization,
      'note': note,
      'description': description,
      'eventColorIndex': eventColorIndex,
      'allDay': allDay,
      'done': done,
      'recipients': recipients, // Store only recipient IDs
      'ownerID': ownerID, // Store owner ID
      'updateHistory': updateHistory, // Store update history
    };
  }

  // Convert JSON to EventDTO
  factory EventDTO.fromJson(Map<String, dynamic> json) {
    return EventDTO(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      title: json['title'] as String,
      groupId: json['groupId'] as String?,
      recurrenceRuleId: json['recurrenceRuleId'] as String?, // Parse recurrence rule ID
      localization: json['localization'] as String?,
      note: json['note'] as String?,
      description: json['description'] as String?,
      eventColorIndex: json['eventColorIndex'] as int,
      allDay: json['allDay'] as bool? ?? false,
      done: json['done'] as bool? ?? false,
      recipients: List<String>.from(json['recipients'] ?? []), // Parse recipient IDs
      ownerID: json['ownerID'] as String,
      updateHistory: List<Map<String, dynamic>>.from(json['updateHistory'] ?? [])
          .map((update) => {
                'userId': update['userId'],
                'updatedAt': DateTime.parse(update['updatedAt']),
              })
          .toList(), // Parse update history
    );
  }
}
