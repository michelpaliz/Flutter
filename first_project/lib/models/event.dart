class Event {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String note;
  final String? groupId; // Optional property for the group ID

  Event({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.note,
    this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'note': note,
      'groupId': groupId,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      note: json['note'],
      groupId: json['groupId'],
    );
  }
}
