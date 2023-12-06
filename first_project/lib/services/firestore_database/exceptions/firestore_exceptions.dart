class UserNotFoundException implements Exception {
  final String message = 'User not found.';
}

class EventNotFoundException implements Exception {
  final String message = 'Event not found.';
}