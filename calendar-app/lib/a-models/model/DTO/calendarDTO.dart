import 'package:first_project/a-models/model/group_data/calendar/calendar.dart';

class CalendarDTO {
  final String id;
  final String name;
  final List<String> eventIds; // Use event IDs instead of full Event objects

  CalendarDTO({
    required this.id,
    required this.name,
    required this.eventIds,
  });

  // Convert Calendar model to CalendarDTO
  factory CalendarDTO.fromCalendar(Calendar calendar) {
    return CalendarDTO(
      id: calendar.id,
      name: calendar.name,
      eventIds: calendar.events.map((event) => event.id).toList(), // Extract event IDs
    );
  }

  // Convert DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'eventIds': eventIds, // Save only event IDs
    };
  }

  // Convert JSON to CalendarDTO
  factory CalendarDTO.fromJson(Map<String, dynamic> json) {
    return CalendarDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      eventIds: List<String>.from(json['eventIds'] ?? []),
    );
  }
}
