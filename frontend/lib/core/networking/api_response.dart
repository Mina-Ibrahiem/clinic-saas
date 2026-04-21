class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.errors,
  });

  final bool success;
  final String message;
  final T? data;
  final Object? errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? rawData) mapper,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: (json['message'] as String?) ?? '',
      data: mapper(json['data']),
      errors: json['errors'],
    );
  }
}
