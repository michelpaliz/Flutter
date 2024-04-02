class NotificationUser {
  final String id;
  final String ownerId; // Add this field to reference the owner's ID
  final String title;
  final String message;
  final DateTime _timestamp;
  final bool hasQuestion;
  final String question;
  final bool isAnswered; // Add the isAnswered field

  NotificationUser({
    required this.id,
    required this.ownerId, // Initialize the ownerId field
    required this.title,
    required this.message,
    required DateTime timestamp,
    // These attributes are set with default values and won't be required during initial creation.
    this.hasQuestion = false,
    this.question = '', // Include the isAnswered field in the constructor
    this.isAnswered = false, // Initialize the isAnswered field
  }) : _timestamp = timestamp;

  DateTime parseTimestamp(String timestampString) {
    return DateTime.parse(timestampString);
  }

  DateTime get timestamp => _timestamp;

  factory NotificationUser.fromJson(Map<String, dynamic> json) {
    return NotificationUser(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '', // Parse the owner's ID
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? ''),
      hasQuestion: json['hasQuestion'] ?? false,
      question: json['question'] ?? '',
      isAnswered: json['isAnswered'] ?? false, // Parse the isAnswered field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId, // Include ownerId in the JSON representation
      'title': title,
      'message': message,
      'timestamp': _timestamp.toIso8601String(),
      'hasQuestion': hasQuestion,
      'question': question,
      'isAnswered': isAnswered, // Include the isAnswered field in the JSON representation
    };
  }

  @override
  String toString() {
    return 'NotificationUser('
        'id: $id, '
        'ownerId: $ownerId, ' // Include ownerId in the string representation
        'title: $title, '
        'message: $message, '
        'timestamp: $_timestamp, '
        'hasQuestion: $hasQuestion, '
        'question: $question, '
        'isAnswered: $isAnswered)';
  }
}
