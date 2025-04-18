enum NotificationType { alert, reminder, message, update }

enum PriorityLevel { low, medium, high }

enum Category {
  groupCreation,
  groupUpdate,
  groupInvitation,
  userRemoval,
  userInvitation,
  eventReminder,
  taskUpdate,
  message,
  systemAlert,
  actionRequired,
  achievement,
  billing,
  systemUpdate,
  feedbackRequest,
  errorReport,
}

class NotificationUser {
  final String id;
  final String senderId;
  final String recipientId;
  final String title;
  final String message;
  final DateTime _timestamp;
  final Map<String, String> questionsAndAnswers;
  final List<String>? groupId; // ✅ Changed to List<String>?
  bool _isRead;
  final NotificationType type;
  final PriorityLevel priority;
  final Category category;

  NotificationUser({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.title,
    required this.message,
    required DateTime timestamp,
    this.questionsAndAnswers = const {},
    this.groupId,
    bool isRead = false,
    this.type = NotificationType.message,
    this.priority = PriorityLevel.medium,
    required this.category,
  })  : _timestamp = timestamp,
        _isRead = isRead;

  DateTime get timestamp => _timestamp;
  bool get isRead => _isRead;

  set isRead(bool value) {
    _isRead = value;
  }

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationUser(
        id: json['id'] ?? '',
        senderId: json['senderId'] ?? '',
        recipientId: json['recipientId'] ?? '',
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'])
            : DateTime.now(),
        questionsAndAnswers: json['questionsAndAnswers'] != null
            ? Map<String, String>.from(json['questionsAndAnswers'])
            : {},
        groupId: (json['groupId'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        isRead: json['isRead'] ?? false,
        type:
            json['type'] is int && json['type'] < NotificationType.values.length
                ? NotificationType.values[json['type']]
                : NotificationType.message,
        priority: json['priority'] is int &&
                json['priority'] < PriorityLevel.values.length
            ? PriorityLevel.values[json['priority']]
            : PriorityLevel.medium,
        category:
            json['category'] is int && json['category'] < Category.values.length
                ? Category.values[json['category']]
                : Category.message,
      );
    } catch (e) {
      print('Error parsing NotificationUser from JSON: $e');
      return NotificationUser(
        id: '',
        senderId: '',
        recipientId: '',
        title: 'Unknown',
        message: 'Error in notification',
        timestamp: DateTime.now(),
        questionsAndAnswers: {},
        groupId: [],
        isRead: false,
        type: NotificationType.message,
        priority: PriorityLevel.medium,
        category: Category.message,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'timestamp': _timestamp.toIso8601String(),
      'questionsAndAnswers': questionsAndAnswers,
      'groupId': groupId,
      'isRead': _isRead,
      'type': type.index,
      'priority': priority.index,
      'category': category.index,
    };
  }

  @override
  String toString() {
    return 'NotificationUser('
        'id: $id, '
        'senderId: $senderId, '
        'recipientId: $recipientId, '
        'title: $title, '
        'message: $message, '
        'timestamp: $_timestamp, '
        'questionsAndAnswers: $questionsAndAnswers, '
        'groupId: $groupId, '
        'isRead: $_isRead, '
        'type: $type, '
        'priority: $priority, '
        'category: $category)';
  }
}
