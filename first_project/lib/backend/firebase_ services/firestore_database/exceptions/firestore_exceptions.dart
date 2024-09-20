class UserNotFoundException implements Exception {
  final String message = 'User not found.';
}

class EventNotFoundException implements Exception {
  final String message = 'Event not found.';
}

class UsernameAlreadyTakenException implements Exception {
  final String message = "Username already taken ";
}

class unwantedCharactersUsername implements Exception {
  final String message = "Username contains invalid characters ";
}
