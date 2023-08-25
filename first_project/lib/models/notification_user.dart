class NotificationUser {
  final String id;
  final String title;
  final String message;
  final DateTime _timestamp;
  final bool hasQuestion;
  final String question;
  bool isAnswered; // Add this field for storing whether the user answered

  NotificationUser({
    required this.id,
    required this.title,
    required this.message,
    required DateTime timestamp,
    this.hasQuestion = false,
    this.question = '',
    this.isAnswered = false, // Initialize the isAnswered field
  }) : _timestamp = timestamp;

  DateTime parseTimestamp(String timestampString) {
    return DateTime.parse(timestampString);
  }

// Define a getter for timestamp
  DateTime get timestamp => _timestamp;
  
  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? ''),
      hasQuestion: json['hasQuestion'] ?? false,
      question: json['question'] ?? '',
      isAnswered: json['isAnswered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': _timestamp.toIso8601String(),
      'hasQuestion': hasQuestion,
      'question': question,
      'isAnswered': isAnswered,
    };
  }

  @override
  String toString() {
    return 'NotificationUser('
        'id: $id, '
        'title: $title, '
        'message: $message, '
        'timestamp: $_timestamp, '
        'hasQuestion: $hasQuestion, '
        'question: $question, '
        'isAnswered: $isAnswered)';
  }
}
