class NotificationUser {
  final String id;
  final String message;
  final DateTime timestamp;

  NotificationUser({
    required this.id,
    required this.message,
    required this.timestamp,
  });

  // Factory constructor to convert JSON data into a NotificationUser object
  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? ''),
    );
  }

  // Method to convert the NotificationUser object into JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'NotificationUser('
        'id: $id, '
        'message: $message, '
        'timestamp: $timestamp)';
  }
}
