import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/app_exception.dart';
import 'api_response.dart';

class SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) debugPrint('HTTP ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('HTTP ${response.statusCode} ${response.requestOptions.path}');
    }
    handler.next(response);
  }
}

class ApiClient {
  const ApiClient(this.dio);
  final Dio dio;

  Future<T> get<T>(
    String path,
    T Function(Object? json) decode, {
    Map<String, dynamic>? query,
  }) => _send(() => dio.get<dynamic>(path, queryParameters: query), decode);
  Future<T> post<T>(
    String path,
    T Function(Object? json) decode, {
    Object? data,
  }) => _send(() => dio.post<dynamic>(path, data: data), decode);

  Future<T> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object? json) decode,
  ) async {
    try {
      final response = await request();
      final raw = response.data;
      if (raw is! Map) throw const AppException('服务器响应格式不正确。');
      final envelope = ApiResponse<T>.fromJson(
        Map<String, dynamic>.from(raw),
        decode,
      );
      if (envelope.code != 0) {
        throw AppException(
          envelope.message,
          code: envelope.code,
          type: AppErrorType.business,
        );
      }
      return envelope.data;
    } on AppException {
      rethrow;
    } on DioException catch (error) {
      throw _mapDioError(error);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unexpected response processing error: $error');
      }
      throw const AppException('发生未知错误，请稍后重试。');
    }
  }

  AppException _mapDioError(DioException error) {
    final raw = error.response?.data;
    if (raw is Map) {
      final message = raw['message'] as String?;
      final code = (raw['code'] as num?)?.toInt();
      if (message != null) {
        return AppException(
          message,
          code: code,
          type: error.response?.statusCode == 401
              ? AppErrorType.unauthorized
              : AppErrorType.business,
        );
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AppException('请求超时，请检查网络后重试。', type: AppErrorType.timeout);
    }
    if (error.type == DioExceptionType.connectionError) {
      return const AppException(
        '无法连接服务器，请确认服务是否可用。',
        type: AppErrorType.connection,
      );
    }
    if (error.response?.statusCode == 401) {
      return const AppException(
        '登录已过期，请重新登录。',
        type: AppErrorType.unauthorized,
      );
    }
    return const AppException('请求失败，请稍后重试。');
  }
}
