class ApiResponse<T> {
  const ApiResponse({
    required this.code,
    required this.message,
    required this.data,
    this.timestamp,
  });
  final int code;
  final String message;
  final T data;
  final String? timestamp;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) decode,
  ) => ApiResponse(
    code: (json['code'] as num?)?.toInt() ?? -1,
    message: json['message'] as String? ?? 'Unknown response',
    data: decode(json['data']),
    timestamp: json['timestamp'] as String?,
  );
}
