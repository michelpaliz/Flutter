import 'package:first_project/a-models/model/user_data/notification_user.dart';

class NotificationUserDTO {
  final String id;
  final String senderId;
  final String recipientId;
  final String title;
  final String message;
  final String timestamp; // Changed to String for easier transfer
  final Map<String, String> questionsAndAnswers;
  final String? groupId;
  final bool isRead;
  final NotificationType type;
  final PriorityLevel priority;
  final Category category;

  NotificationUserDTO({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.questionsAndAnswers = const {},
    this.groupId,
    required this.isRead,
    required this.type,
    required this.priority,
    required this.category,
  });

  factory NotificationUserDTO.fromJson(Map<String, dynamic> json) {
    return NotificationUserDTO(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null ? json['timestamp'] : DateTime.now().toIso8601String(),
      questionsAndAnswers: json['questionsAndAnswers'] != null ? Map<String, String>.from(json['questionsAndAnswers']) : {},
      groupId: json['groupId'],
      isRead: json['isRead'] ?? false,
      type: json['type'] != null && json['type'] is int && json['type'] < NotificationType.values.length
          ? NotificationType.values[json['type']]
          : NotificationType.message,
      priority: json['priority'] != null && json['priority'] is int && json['priority'] < PriorityLevel.values.length
          ? PriorityLevel.values[json['priority']]
          : PriorityLevel.medium,
      category: json['category'] != null && json['category'] is int && json['category'] < Category.values.length
          ? Category.values[json['category']]
          : Category.message,
    );
  }

    // Method to create a DTO from a NotificationUser object
  static NotificationUserDTO fromNotification(NotificationUser notification) {
    return NotificationUserDTO(
      id: notification.id,
      senderId: notification.senderId,
      recipientId: notification.recipientId,
      title: notification.title,
      message: notification.message,
      timestamp: notification.timestamp.toString(), // Assuming this is a string
      questionsAndAnswers: notification.questionsAndAnswers,
      groupId: notification.groupId,
      isRead: notification.isRead,
      type: notification.type,
      priority: notification.priority,
      category: notification.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'title': title,
      'message': message,
      'timestamp': timestamp,
      'questionsAndAnswers': questionsAndAnswers,
      'groupId': groupId,
      'isRead': isRead,
      'type': type.index,
      'priority': priority.index,
      'category': category.index,
    };
  }


  @override
  String toString() {
    return 'NotificationUserDTO('
        'id: $id, '
        'senderId: $senderId, '
        'recipientId: $recipientId, '
        'title: $title, '
        'message: $message, '
        'timestamp: $timestamp, '
        'questionsAndAnswers: $questionsAndAnswers, '
        'groupId: $groupId, '
        'isRead: $isRead, '
        'type: $type, '
        'priority: $priority, '
        'category: $category)';
  }
}
