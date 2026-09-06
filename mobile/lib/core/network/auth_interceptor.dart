import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import '../../features/auth/domain/auth_models.dart';
import 'api_endpoints.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._dio,
    required this.storage,
    required this.onSessionExpired,
  });
  final Dio _dio;
  final TokenStorage storage;
  final void Function() onSessionExpired;
  Future<bool>? _refreshFlight;
  int refreshRequestCount = 0;
  static const _publicAuthPaths = {
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.refresh,
  };

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] != true) {
      final token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final canRefresh =
        err.response?.statusCode == 401 &&
        !_publicAuthPaths.contains(request.path) &&
        request.extra['authRetried'] != true;
    if (!canRefresh) return handler.next(err);
    final success = await (_refreshFlight ??= _refresh()).whenComplete(
      () => _refreshFlight = null,
    );
    if (!success) return handler.next(err);
    try {
      final token = await storage.getAccessToken();
      request.headers['Authorization'] = 'Bearer $token';
      request.extra['authRetried'] = true;
      handler.resolve(await _dio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() async {
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return await _expire();
    refreshRequestCount++;
    try {
      final refreshDio = Dio(_dio.options);
      refreshDio.httpClientAdapter = _dio.httpClientAdapter;
      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'skipAuth': true}),
      );
      final envelope = response.data;
      if (envelope == null ||
          envelope['code'] != 0 ||
          envelope['data'] is! Map) {
        return await _expire();
      }
      await storage.saveTokens(
        TokenPair.fromJson(Map<String, dynamic>.from(envelope['data'] as Map)),
      );
      return true;
    } catch (_) {
      return await _expire();
    }
  }

  Future<bool> _expire() async {
    await storage.clearTokens();
    onSessionExpired();
    return false;
  }
}
