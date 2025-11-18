/// Base application exception used to standardize error handling.
class AppException implements Exception {
  const AppException({required this.code, this.message, this.cause});

  /// Localization key that describes the error.
  final String code;

  /// Optional human readable message for logs.
  final String? message;

  /// Optional original error for debugging.
  final Object? cause;

  @override
  String toString() =>
      'AppException(code: $code, message: $message, cause: $cause)';
}

/// Specialized exception for authentication failures.
class AuthFailure extends AppException {
  const AuthFailure({required super.code, super.message, super.cause});
}
