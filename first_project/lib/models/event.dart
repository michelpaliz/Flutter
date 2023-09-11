class Event {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final String? groupId; // Optional property for the group ID
  bool done;

  Event({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.note,
    this.groupId,
    this.done = false, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'note': note,
      'groupId': groupId,
      'done': done, // Added 'done' field to the map
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      note: json['note'],
      groupId: json['groupId'],
      done: json['done'] ?? false, // Added 'done' field
    );
  }
}
