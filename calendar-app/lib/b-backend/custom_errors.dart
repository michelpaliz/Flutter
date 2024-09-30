class CustomException implements Exception {
  final String message;
  final int statusCode;
  final String responseBody;

  CustomException(
    this.message, {
    this.statusCode = 0,  // Provide a default value for statusCode
    this.responseBody = '', // Provide a default value for responseBody
  });

  @override
  String toString() {
    return 'CustomException: $message (Status Code: $statusCode, Response: $responseBody)';
  }
}
