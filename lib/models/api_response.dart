class ApiError {
  final String message;
  final String? code;
  ApiError({required this.message, this.code});
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;

  ApiResponse({required this.success, this.data, this.message, this.error});

  factory ApiResponse.success({T? data, String? message}) =>
      ApiResponse(success: true, data: data, message: message);

  factory ApiResponse.failure({required String message, String? code}) =>
      ApiResponse(success: false, error: ApiError(message: message, code: code), message: message);
}
