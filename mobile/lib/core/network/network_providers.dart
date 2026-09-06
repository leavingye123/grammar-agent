import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../storage/token_storage.dart';
import '../../features/auth/presentation/auth_controller.dart';
import 'api_client.dart';
import 'auth_interceptor.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 12),
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(
      dio: dio,
      storage: ref.read(tokenStorageProvider),
      onSessionExpired: () => ref.read(authProvider.notifier).expireSession(),
    ),
  );
  dio.interceptors.add(SafeLogInterceptor());
  return dio;
});
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(dioProvider)),
);
