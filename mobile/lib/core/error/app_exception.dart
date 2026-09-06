enum AppErrorType { connection, timeout, unauthorized, business, unknown }

class AppException implements Exception {
  const AppException(
    this.message, {
    this.code,
    this.type = AppErrorType.unknown,
  });
  final String message;
  final int? code;
  final AppErrorType type;
  @override
  String toString() => message;
}
