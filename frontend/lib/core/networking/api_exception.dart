class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  final String message;
  final int? statusCode;
  final Object? errors;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}
