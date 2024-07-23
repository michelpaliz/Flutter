enum NotificationType { alert, reminder, message, update }
enum PriorityLevel { low, medium, high }

class NotificationUser {
  final String id;
  final String ownerId; // Reference to the owner's ID
  final String title;
  final String message;
  final DateTime _timestamp;
  final Map<String, String> questionsAndAnswers;
  final String? groupId; // Optional groupId
  bool _isRead; // Indicates whether the notification has been read
  final NotificationType type; // Type of the notification
  final PriorityLevel priority; // Priority level of the notification

  NotificationUser({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.message,
    required DateTime timestamp,
    this.questionsAndAnswers = const {},
    this.groupId,
    bool isRead = false,
    this.type = NotificationType.message,
    this.priority = PriorityLevel.medium,
  })  : _timestamp = timestamp,
        _isRead = isRead;

  DateTime get timestamp => _timestamp;
  bool get isRead => _isRead;

  set isRead(bool value) {
    _isRead = value;
  }

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? ''),
      questionsAndAnswers: Map<String, String>.from(json['questionsAndAnswers'] ?? {}),
      groupId: json['groupId'],
      isRead: json['isRead'] ?? false,
      type: NotificationType.values[json['type'] ?? 0],
      priority: PriorityLevel.values[json['priority'] ?? 1],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'message': message,
      'timestamp': _timestamp.toIso8601String(),
      'questionsAndAnswers': questionsAndAnswers,
      'groupId': groupId,
      'isRead': _isRead,
      'type': type.index,
      'priority': priority.index,
    };
  }

  @override
  String toString() {
    return 'NotificationUser('
        'id: $id, '
        'ownerId: $ownerId, '
        'title: $title, '
        'message: $message, '
        'timestamp: $_timestamp, '
        'questionsAndAnswers: $questionsAndAnswers, '
        'groupId: $groupId, '
        'isRead: $_isRead, '
        'type: $type, '
        'priority: $priority)';
  }
}
