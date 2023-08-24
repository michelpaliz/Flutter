class NotificationUser {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool hasQuestion;
  final String? question;

  NotificationUser({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.hasQuestion = false,
    this.question,
  });

  // Factory constructor to convert JSON data into a NotificationUser object
  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? ''),
      hasQuestion: json['hasQuestion'] ?? false,
      question: json['question'] ?? '',
    );
  }

  // Method to convert the NotificationUser object into JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'hasQuestion': hasQuestion,
      'question': question,
    };
  }

  @override
  String toString() {
    return 'NotificationUser('
        'id: $id, '
        'title: $title, '
        'message: $message, '
        'timestamp: $timestamp, '
        'hasQuestion: $hasQuestion, '
        'question: $question)';
  }
}
